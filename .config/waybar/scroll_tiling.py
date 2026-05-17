#!/usr/bin/env python3

import json
import os
import subprocess
import sys

import i3ipc

TILING_STATE_JSON = os.path.join(os.environ["HOME"],
                                 ".config/scroll/tiling_state.json")

i3 = i3ipc.Connection()
workspaces = i3.get_workspaces()
current_output = os.environ.get("WAYBAR_OUTPUT_NAME")
for ws in workspaces:
  if ws.output == current_output and ws.visible:
    tiling_state = None
    try:
      with open(TILING_STATE_JSON) as fp:
        tiling_state = json.load(fp).get(ws.name)
    except FileNotFoundError:
      pass
    if tiling_state is not None:
      _, mode_string = tiling_state.split(":")
      mode = "" if mode_string == "tile" else ""
    else:
      mode = ""
    orientation = "" if ws.ipc_data["orientation"] == "horizontal" else ""
    class_ = "focused" if ws.focused else "inactive"
    print(f'{mode} {orientation}')
    break
