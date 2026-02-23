#!/usr/bin/env python3

import json
import os
import sys

WAYBAR_CONFIG = os.path.join(
    os.environ["HOME"],
    ".config/waybar/config"
)

ICON_DICT = None


def get_ws_icon(name):
  global ICON_DICT
  if not ICON_DICT:
    with open(WAYBAR_CONFIG) as fp:
      waybar_config = json.load(fp)
    ICON_DICT = waybar_config["niri/workspaces"]["format-icons"]

  icon = ICON_DICT.get(name)
  if not icon:
    icon = ICON_DICT["default"]

  return icon


if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(get_ws_icon(sys.argv[1]))
