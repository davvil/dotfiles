#!/usr/bin/env python3
# Adapted from the many ideas shared at: https://github.com/YaLTeR/niri/discussions/329

import argparse
from collections import Counter
import json
import os
import subprocess
import sys
import time

# the found scratchpad window (id, workspace_id, is_focused, is_floating)
scratch_window = {}
# the focused workspace data
focused_workspace = {}
# the scratchpad workspace name
scratch_workspace = os.getenv("NS_WORKSPACE", "Scratch")
n_ws = Counter()  # Indexed by output

def niri_cmd(cmd_args):
    print(cmd_args)
    subprocess.run(["niri", "msg", "action"] + cmd_args)

def move_window_to_scratchpad(window_id, animations):
    niri_cmd(["move-window-to-workspace", "--window-id", str(window_id), scratch_workspace, "--focus=false"])
    if animations:
        niri_cmd(["move-window-to-tiling", "--id", str(window_id)])

def bring_scratchpad_window_to_focus(window_id, args):
    niri_cmd(["move-workspace-to-monitor", "--reference", scratch_workspace, focused_workspace["output"]])
    niri_cmd(["move-workspace-to-index", "--reference", scratch_workspace, str(n_ws[focused_workspace["output"]]-1)])
    niri_cmd(["move-window-to-workspace", "--window-id", str(window_id), str(focused_workspace["name"])])
    if args.multi_monitor:
        niri_cmd(["move-window-to-monitor", "--id", str(window_id), focused_workspace["output"]])
    if args.animations and not scratch_window["is_floating"]:
        niri_cmd(["move-window-to-floating", "--id", str(window_id)])
    niri_cmd(["focus-window", "--id", str(window_id)])
    if args.width:
      niri_cmd(["set-window-width", "--id", str(window_id), args.width])
    if args.height:
      niri_cmd(["set-window-height", "--id", str(window_id), args.height])
    time.sleep(0.1)
    niri_cmd(["center-window", "--id", str(window_id)])

def find_scratch_window(args, windows):
    for window in windows:
        if (args.app_id and window["app_id"] == args.app_id) or (args.title and window["title"] == args.title):
            scratch_window["id"] = window["id"]
            scratch_window["workspace_id"] = window["workspace_id"]
            scratch_window["is_focused"] = window["is_focused"]
            scratch_window["is_floating"] = window["is_floating"]
            break

def fetch_focused_workspace():
    props = subprocess.run(
        ["niri", "msg", "--json", "workspaces"],
        capture_output=True,
        text=True,
    )
    workspaces = json.loads(props.stdout)

    # get the focused workspace
    for workspace in workspaces:
        n_ws[workspace["output"]] += 1
        if workspace["is_focused"]:
            global focused_workspace
            focused_workspace = workspace

    return focused_workspace["id"]

def ns(parser):
    args = parser.parse_args()

    props = subprocess.run(
        ["niri", "msg", "--json", "windows"],
        capture_output=True,
        text=True,
    )
    windows = json.loads(props.stdout)

    find_scratch_window(args, windows)

    # scratchpad does not yet exist, spawn?
    if not scratch_window:
        if args.spawn:
            niri_cmd(["spawn", "--"] + args.spawn.split(' '))
            sys.exit(0)
        else:
            parser.print_help()
            sys.exit(1)

    window_id = scratch_window["id"]

    # the scratchpad window exists and it's focused
    if not scratch_window["is_focused"]:
        workspace_id = fetch_focused_workspace()
        # the window is not in the focused workspace
        if scratch_window["workspace_id"] != workspace_id:
            bring_scratchpad_window_to_focus(window_id, args)
            return

    move_window_to_scratchpad(window_id, args.animations)

def main():
    parser = argparse.ArgumentParser(prog='nscratch', description='Niri Scratchpad support')
    group = parser.add_mutually_exclusive_group(required=True)

    group.add_argument('-id', '--app-id', help='The application identifier')
    group.add_argument('-t', '--title', help='The application title')
    parser.add_argument('-s', '--spawn', help='The process name to spawn when non-existing')
    parser.add_argument('-a', '--animations', action='store_true', help='Enable animations')
    parser.add_argument('-m', '--multi-monitor', action='store_true', help='Multi-monitor support')
    parser.add_argument('-W', '--width', help='Resize window to this width')
    parser.add_argument('-H', '--height', help='Resize window to this height')

    ns(parser)

if __name__ == "__main__":
    main()
