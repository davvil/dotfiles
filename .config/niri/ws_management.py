#!/usr/bin/env python3

from argparse import ArgumentParser
import enum
import os
import re
import subprocess
import sys

WORKSPACES_PATH = os.path.join(os.environ["HOME"],
                               ".config/niri/named_workspaces.kdl")
ROFI = os.path.join(os.environ["HOME"],
                    "rofi/bin/rofi")

workspace_line_re = re.compile(r'workspace\s+"(.*)"')


def run_rofi(options):
  subp_run = subprocess.run(
      [ROFI,
       "-show-icons",
       "-dmenu",
       "-auto-select",
       "-matching", "regex",
       "-filter", "^",
       "-p", " Change to WS:",
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

def read_workspaces():
  workspaces = []
  with open(WORKSPACES_PATH) as fp:
    for l in fp:
      match = workspace_line_re.match(l.strip())
      if match:
        workspaces.append(match.group(1))

  return workspaces


class Actions(enum.StrEnum):
  FOCUS = "focus"
  MOVE_WINDOW = "move-window"


def main():
  argparser = ArgumentParser()
  argparser.add_argument(
      "action",
      choices=Actions,
  )
  args = argparser.parse_args()

  workspaces = read_workspaces()
  selected_ws = run_rofi(workspaces)
  if selected_ws:
    match args.action:
      case Actions.FOCUS:
        niri_cmd("action move-workspace-to-index 1")
        niri_cmd(f"action focus-workspace {selected_ws}")
        niri_cmd(f"action move-workspace-to-index --reference {selected_ws} 1")
      case Actions.MOVE_WINDOW:
        niri_cmd(f"action move-window-to-workspace --focus false {selected_ws}")

if __name__ == "__main__":
  main()

