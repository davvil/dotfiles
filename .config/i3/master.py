#!/usr/bin/env python3

import i3ipc
import sys
import Xlib.display

from ewmh import EWMH

import autotag

windowLikeContainerLayouts = ["tabbed", "stacked"]

def selectContainerForSwap(c):
    return c.layout in windowLikeContainerLayouts or not c.nodes

def selectContainerForFocus(c):
    return not c.nodes

# Checks if a window is visible via ewmh properties
def isVisible(w, ewmh, dpy):
    win = dpy.create_resource_object("window", w.window)
    return "_NET_WM_STATE_HIDDEN" not in ewmh.getWmState(win, str=True)

def traverseTree(container, select):
    if select(container):
        yield container
    else:
        for n in container.nodes:
            yield from traverseTree(n, select)

if len(sys.argv) > 1 and sys.argv[1] == "-f":
    action = "focus"
    selectFunction = selectContainerForFocus
    ewmh = EWMH()
    dpy = Xlib.display.Display()
else:
    action = "swap"
    selectFunction = selectContainerForSwap
    ewmh = None
    dpy = None

i3 = i3ipc.Connection()
focusedContainer = i3.get_tree().find_focused()
c = focusedContainer
while c and c.type == "con":
    c = c.parent
    if c and c.type == "con" and c.layout in windowLikeContainerLayouts:
        focusedContainer = c
if focusedContainer:
    wsTree = focusedContainer.workspace()
    biggestContainer = None
    biggestSize = 0
    for c in traverseTree(wsTree, selectFunction):
        totalSize = c.rect.width * c.rect.height
        if totalSize > biggestSize:
            if action == "focus" and not isVisible(c, ewmh, dpy):
                continue
            biggestContainer = c
            biggestSize = totalSize
    if action == "swap":
        focusedContainer.command("swap container with con_id %s" % biggestContainer.id)
        autotag.tagTree(i3, None)
    else:
        biggestContainer.command("focus")

