#!/usr/bin/env python3

import i3ipc
import os

from ws_icons import get_ws_icon


i3 = i3ipc.Connection()
wsNames = set([w.name for w in i3.get_workspaces()])
wsNames = sorted(list(set(["General", "web"]) | set(wsNames)))

wsNamesWithIcons = []
for ws in wsNames:
  icon = get_ws_icon(ws)
  wsNamesWithIcons.append(f'{ws}\0icon\x1f<span font="Symbols Nerd Font" color="white">{icon}</span>')
print("\n".join(wsNamesWithIcons))
