#!/usr/bin/env python3

import functools
import json
import sys
import subprocess
from typing import Any

def niri_cmd(command: str):
  process_stats = subprocess.run(
    ["niri", "msg", "--json"] + command.split(),
    capture_output=True,
  )
  return process_stats


def window_cmp(w1: dict[str, Any], w2: dict[str, Any]) -> int:
  col1, row1 = w1['layout']['pos_in_scrolling_layout']
  col2, row2 = w2['layout']['pos_in_scrolling_layout']
  if col1 < col2:
    return -1
  elif col2 > col1:
    return 1
  elif row1 < row2:
    return -1
  elif row2 > row1:
    return 1
  else:
    return 0  # Shouldn't happen

def main():
  window_nr = int(sys.argv[1]) - 1

  niri_out = niri_cmd("windows")
  window_list = json.loads(niri_out.stdout.decode())
  window_list.sort(key=functools.cmp_to_key(window_cmp))
  if window_nr >= len(window_list):
    return
  window_id = window_list[window_nr]['id']
  niri_cmd(f"action focus-window --id {window_id}")


if __name__ == "__main__":
  main()
