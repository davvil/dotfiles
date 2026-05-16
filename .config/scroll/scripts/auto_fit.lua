-- auto_fit.lua
--
-- Automatically fits windows equally when new non-floating windows are
-- created or closed:
--   - Vertical mode: always runs `fit_size v all equal`
--   - Horizontal mode: runs `fit_size h all equal` only when scroll mode
--     is OFF for that workspace.
--
-- Scroll mode is per-workspace.  Toggling it affects only the currently
-- focused workspace.
--
-- State (scroll mode + layout mode per workspace) is persisted to
-- ~/.config/scroll/tiling_state.json to survive compositor restarts.
--
-- Usage (in scroll config):
--   lua .config/scroll/scripts/auto_fit.lua
--   bindsym $mod+<key> lua .config/scroll/scripts/auto_fit.lua toggle
--   bindsym $mod+<key> lua .config/scroll/scripts/auto_fit.lua set_mode t

local args, state = ...

local scroll = require("scroll")
local scroll_modes = {}
local layout_modes = {}  -- workspace_name -> "horizontal"/"vertical"
local STATE_FILE = os.getenv("HOME") .. "/.config/scroll/tiling_state.json"

local function save_state()
  local f = io.open(STATE_FILE, "w")
  if f == nil then return end
  -- Collect all workspace names that have any state.
  local names = {}
  for k in pairs(scroll_modes) do names[k] = true end
  for k in pairs(layout_modes) do names[k] = true end
  local parts = {}
  for name in pairs(names) do
    local mode = layout_modes[name] or "horizontal"
    local smode = scroll_modes[name] and "scroll" or "tile"
    parts[#parts + 1] = '  "' .. name .. '": "' .. mode .. ':' .. smode .. '"'
  end
  f:write("{\n" .. table.concat(parts, ",\n") .. "\n}\n")
  f:close()
end

local function load_state()
  local f = io.open(STATE_FILE, "r")
  if f == nil then return end
  local content = f:read("*a")
  f:close()
  for name, mode, smode in content:gmatch('"([^"]+)"%s*:%s*"(%a+):(%a+)"') do
    if mode == "vertical" or mode == "horizontal" then
      layout_modes[name] = mode
    end
    if smode == "scroll" then
      scroll_modes[name] = true
      scroll.state_set_value(state, "scroll:" .. name, true)
    end
  end
end

-- Restore a saved layout mode for a workspace, if one exists.
-- Uses workspace_set_mode directly since during config reload or workspace
-- creation there may be no container, and decorations get rebuilt anyway.
local function restore_mode(workspace)
  local name = scroll.workspace_get_name(workspace)
  if name == nil then return end
  local mode = layout_modes[name]
  if mode == nil then return end
  scroll.workspace_set_mode(workspace, { mode = mode })
end

load_state()

-- Restore modes for workspaces that already exist at load time.
for _, output in ipairs(scroll.root_get_outputs()) do
  for _, ws in ipairs(scroll.output_get_workspaces(output)) do
    restore_mode(ws)
  end
end

-- ── Actions (invoked from keybindings) ─────────────────────────────────────

if args[1] == "toggle" then
  local workspace = scroll.focused_workspace()
  if workspace == nil then
    return
  end
  local name = scroll.workspace_get_name(workspace)
  if name == nil then
    return
  end

  -- Use scroll's per-script state (shared across invocations) as the
  -- source of truth.  The JSON file is only for surviving restarts.
  local key = "scroll:" .. name
  local current = scroll.state_get_value(state, key)
  scroll.state_set_value(state, key, not current)
  scroll_modes[name] = not current
  local mode_str = scroll_modes[name] and "ON" or "OFF"
  save_state()
  scroll.command(nil, 'exec pkill -SIGRTMIN+1 waybar')
  return
end

if args[1] == "set_mode" then
  -- Pass the focused container so that scroll.command sets up
  -- handler_context.container (needed by set_mode for container_update)
  -- without calling seat_set_raw_focus (which corrupts border state).
  local container = scroll.focused_container()
  scroll.command(container, "set_mode " .. table.concat(args, " ", 2))

  -- Persist the resulting mode.
  local workspace = scroll.focused_workspace()
  if workspace ~= nil then
    local name = scroll.workspace_get_name(workspace)
    if name ~= nil then
      local mode_info = scroll.workspace_get_mode(workspace)
      if mode_info ~= nil and mode_info.mode ~= "none" then
        layout_modes[name] = mode_info.mode
      else
        layout_modes[name] = nil
      end
      save_state()
      scroll.command(nil, 'exec pkill -SIGRTMIN+1 waybar')
    end
  end
  return
end

-- ── Callbacks ────────────────────────────────────────────────────────────

local pending_new = {}

local function is_scroll_mode(workspace)
  local name = scroll.workspace_get_name(workspace)
  if name == nil then
    return false
  end
  return scroll.state_get_value(state, "scroll:" .. name) == true
end

-- Returns a list of fit_size commands for the workspace, or an empty
-- table if no auto-fit should happen.
local function fit_commands_for(workspace)
  local mode_info = scroll.workspace_get_mode(workspace)
  if mode_info == nil then
    return {}
  end

  local mode = mode_info.mode

  if mode == "vertical" then
    -- Always auto-fit in vertical mode
    return { "fit_size v all equal" }
  else
    -- "horizontal" or "none" (default) → horizontal behaviour
    if not is_scroll_mode(workspace) then
      return { "fit_size h all equal", "fit_size v all equal" }
    else
      return { "fit_size v all equal" }
    end
  end

  return {}
end

local function on_view_map(view, _)
  pending_new[view] = true
end

local function on_view_unmap(view, _)
  pending_new[view] = nil

  local container = scroll.view_get_container(view)
  if container == nil then
    return
  end

  if scroll.container_get_floating(container) then
    return
  end

  local workspace = scroll.container_get_workspace(container)
  if workspace == nil then
    return
  end

  local cmds = fit_commands_for(workspace)
  if #cmds == 0 then
    return
  end

  local tiling = scroll.workspace_get_tiling(workspace)
  if tiling == nil or #tiling <= 1 then
    return
  end

  -- N.B. We use "exec scrollmsg" to defer the command to a later event loop
  -- iteration.  During view_unmap the dying view is still in the container
  -- tree, so running fit_size directly would include it in the calculation.
  -- The async scrollmsg IPC roundtrip ensures the tree has been updated first.
  for _, cmd in ipairs(cmds) do
    scroll.command(nil, "exec scrollmsg " .. cmd)
  end
end

local function on_view_focus(view, _)
  if not pending_new[view] then
    return
  end
  pending_new[view] = nil

  local container = scroll.view_get_container(view)
  if container == nil then
    return
  end

  if scroll.container_get_floating(container) then
    return
  end

  local workspace = scroll.container_get_workspace(container)
  if workspace == nil then
    return
  end

  local cmds = fit_commands_for(workspace)
  if #cmds == 0 then
    return
  end

  -- Unlike on_view_unmap, the tree is stable during view_focus, so we can
  -- run the command directly without the exec scrollmsg deferral.
  for _, cmd in ipairs(cmds) do
    scroll.command(nil, cmd)
  end
end

local function on_ipc_workspace(old, new, change, _)
  if change == "empty" and new ~= nil then
    local name = scroll.workspace_get_name(new)
    if name ~= nil and (scroll_modes[name] or layout_modes[name]) then
      local key = "scroll:" .. name
      if scroll.state_get_value(state, key) then
        scroll.state_set_value(state, key, nil)
      end
      scroll_modes[name] = nil
      layout_modes[name] = nil
      save_state()
    end
  end
end

local function on_workspace_create(workspace, _)
  restore_mode(workspace)
end

scroll.add_callback("view_map", on_view_map, nil)
scroll.add_callback("view_unmap", on_view_unmap, nil)
scroll.add_callback("view_focus", on_view_focus, nil)
scroll.add_callback("ipc_workspace", on_ipc_workspace, nil)
scroll.add_callback("workspace_create", on_workspace_create, nil)
