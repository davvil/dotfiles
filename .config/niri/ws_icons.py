#!/usr/bin/env python3

import sys


known_icons = {
    "Mail": "",
    "web": "󰖟",
    "General": "",
    "Meet": "󰘂",
}
default_icon = ""


def get_ws_icon(name):
  return known_icons.get(name, default_icon)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(get_ws_icon(sys.argv[1]))
