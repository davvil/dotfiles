#!/usr/bin/env python

import i3ipc
import os
import sys

i3 = i3ipc.Connection()

outputs = [o for o in i3.get_outputs() if o.active]
if len(outputs) != 2:
    sys.exit(0)

focusedWindow = i3.get_tree().find_focused()
focusedWSName = focusedWindow.workspace().name
focusedOutput = [o for o in outputs if o.current_workspace == focusedWSName][0]
print(focusedOutput.name)
# workspaces() is a function of a container, somwhat strange...
workspaces = focusedWindow.workspaces()
actions = [
    (outputs[0].current_workspace, outputs[1].name),
    (outputs[1].current_workspace, outputs[0].name)
]
for wsName, output in actions:
    ws = [w for w in workspaces if w.name == wsName][0]
    ws.command("move workspace to output %s" % output)
    i3.command("focus output %s" % output)
    i3.command("workspace %s" % wsName)
i3.command("focus output %s" % focusedOutput.name)
