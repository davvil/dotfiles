#!/usr/bin/env python3

import json
import subprocess
import sys

from pprint import pprint


def niri_cmd(command: str):
  subp_run = subprocess.run(
      ["niri", "msg", "--json"] + command.split(),
      capture_output=True,
      text=True,
  )
  if subp_run.stderr:
    print(subp_run.stderr, file=sys.stderr)
  return subp_run


def look_for_new_window():
  process = subprocess.Popen(
      ["niri", "msg", "--json", "event-stream"],
      stdout=subprocess.PIPE,
      text=True,
      bufsize=1,
  )

  for line in process.stdout:
    key, value = json.loads(line).popitem()
    if key == "WindowOpenedOrChanged":
      pprint(value)
      return value["window"]["id"]


if __name__ == "__main__":
  win_id = look_for_new_window()
  niri_cmd(f"action consume-or-expel-window-left  --id {win_id}")
