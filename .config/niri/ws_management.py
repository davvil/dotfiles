#!/usr/bin/env python3

from argparse import ArgumentParser
import enum
import json
import notify2
import os
import re
import subprocess
import sys
import time

WORKSPACES_PATH = os.path.join(os.environ["HOME"],
                               ".config/niri/named_workspaces.kdl")
ROFI = os.path.join(os.environ["HOME"],
                    "rofi/bin/rofi")

workspace_line_re = re.compile(r'workspace\s+"(.*)"')


def run_rofi(title, options, auto_select=True, filter="^"):
  try:
    subp_run = subprocess.run(
        [ROFI,
         "-show-icons",
         "-dmenu",
         "-auto-select" if auto_select else "",
         "-matching", "regex",
         "-filter", filter,
         "-p", title,
         "-fullscreen",
         "-padding", "250"
         "-me-select-entry", "",
         #"-me-accept-entry", "MousePrimary",
         "-fi -theme-str", "listview { lines: 20; }"
         ],
        input="\n".join(options),
        capture_output=True,
        text=True,
        check=True,
    )
  except subprocess.CalledProcessError:
    sys.exit(0)
  return subp_run.stdout.strip()


def niri_cmd(command: str):
  subp_run = subprocess.run(
      ["niri", "msg", "--json"] + command.split(),
      capture_output=True,
      text=True,
  )
  if subp_run.stderr:
    print(subp_run.stderr, file=sys.stderr)
  return subp_run


def send_message(title, message):
    notify2.init("NiriWS")
    notice = notify2.Notification(title, message)
    notice.show()
    return


def read_workspaces():
  workspaces = []
  with open(WORKSPACES_PATH) as fp:
    for l in fp:
      match = workspace_line_re.match(l.strip())
      if match:
        workspaces.append(match.group(1))

  return workspaces


def create_ws(new_ws):
  workspaces = read_workspaces()
  if new_ws in workspaces:
    print(f"Workspace '{new_ws}' already exists. Doing nothing", file=sys.stderr)
    return
  with open(WORKSPACES_PATH, "w") as fp:
    for w in workspaces:
      print(f'workspace "{w}"', file=fp)
    print(f'workspace "{new_ws}"', file=fp)


def delete_ws(del_ws):
  workspaces = read_workspaces()
  if del_ws not in workspaces:
    print(
        f"Workspace '{del_ws}' does not exist. Doing nothing", file=sys.stderr)
    return
  with open(WORKSPACES_PATH, "w") as fp:
    for w in workspaces:
      if w != del_ws:
        print(f'workspace "{w}"', file=fp)


def focus_ws(selected_ws):
  niri_ws = json.loads(niri_cmd("workspaces").stdout)
  focused_output = [ws for ws in niri_ws if ws["is_focused"]][0]["output"]
  niri_cmd("action move-workspace-to-index 1")
  niri_cmd(f"action move-workspace-to-monitor --reference {selected_ws} {focused_output}")
  niri_cmd(f"action focus-workspace {selected_ws}")
  niri_cmd(f"action move-workspace-to-index --reference {selected_ws} 1")


class Actions(enum.StrEnum):
  FOCUS = "focus"
  MOVE_WINDOW = "move-window"
  CREATE_WS = "create-workspace"
  DELETE_WS = "delete-workspace"


rofi_titles = {
    Actions.FOCUS: " Change to WS:",
    Actions.MOVE_WINDOW: " Move window to WS:",
    Actions.CREATE_WS: " Create new WS:",
    Actions.DELETE_WS: " Delete WS:",
}


def get_ws(args):
  if args.workspace:
    selected_ws = args.workspace
  else:
    workspaces = read_workspaces()
    match args.action:
      case Actions.FOCUS:
        selected_ws = run_rofi(rofi_titles[args.action], workspaces)
      case Actions.MOVE_WINDOW:
        selected_ws = run_rofi(rofi_titles[args.action], workspaces)
      case Actions.CREATE_WS:
        selected_ws = run_rofi(
            rofi_titles[args.action], workspaces, auto_select=False, filter="")
      case Actions.DELETE_WS:
        selected_ws = run_rofi(
            rofi_titles[args.action], workspaces, auto_select=False)
  return selected_ws


def main():
  argparser = ArgumentParser()
  argparser.add_argument(
      "action",
      choices=Actions,
  )
  argparser.add_argument(
      "workspace",
      nargs="?",
  )
  args = argparser.parse_args()

  selected_ws = get_ws(args)
  match args.action:
    case Actions.FOCUS:
      focus_ws(selected_ws)
    case Actions.MOVE_WINDOW:
      niri_cmd(f"action move-window-to-workspace --focus false {selected_ws}")
    case Actions.CREATE_WS:
      create_ws(selected_ws)
      send_message("WS Created", f"Created workspace {selected_ws}")
    case Actions.DELETE_WS:
      delete_ws(selected_ws)
      send_message("WS Deleted", f"Deleted workspace {selected_ws}")

if __name__ == "__main__":
  main()

