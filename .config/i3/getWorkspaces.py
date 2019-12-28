#!/usr/bin/env python

import i3ipc

i3 = i3ipc.Connection()
workspaceNames = set([w.name for w in i3.get_workspaces()])
workspaceNames = sorted(list(set(["general", "web"]) | set(workspaceNames)))
print("\n".join(workspaceNames))
