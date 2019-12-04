#!/usr/bin/env python2

import i3

workspaceNames = [w["name"] for w in i3.get_workspaces() if w["name"].strip() and w["name"][0] != "_"]
workspaceNames = list( set(["general", "web"]) | set(workspaceNames) )

print "\n".join(workspaceNames)
