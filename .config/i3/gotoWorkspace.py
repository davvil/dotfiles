#!/usr/bin/env python

import i3ipc
import sys

if len(sys.argv) < 2:
    sys.exit(0)

targetWSName = sys.argv[1]
i3 = i3ipc.Connection()

workspaces = i3.get_workspaces()
try:
    targetWorkspace = [w for w in workspaces if w['name'] == targetWSName][0]
except IndexError:
    targetWorkspace = None
if targetWorkspace and not targetWorkspace['visible']:
    currentWorkspace = [w for w in workspaces if w['focused']][0]
    currentOutput = currentWorkspace['output']
    if targetWorkspace['output'] != currentOutput:
        i3.command("[workspace=\"%s\"]move workspace to output %s" % (targetWSName, currentOutput))
i3.command("workspace " + targetWSName)
