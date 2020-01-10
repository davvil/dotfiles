#!/usr/bin/env python3

import signal
import os
from collections import defaultdict

import i3ipc

from gotoWorkspace import gotoWorkspace

wsHistory = defaultdict(list)  # Indexed by monitor
i3 = None
pidFile = os.path.join(os.environ["HOME"], ".config", "i3", "wsBackAndForth.pid")


def actualWorkspace(wsName):
    global i3
    workspaces = i3.get_workspaces()
    try:
        return [ws for ws in workspaces if ws.name == wsName][0]
    except IndexError:
        return None


def focusWorkspaceEvent(my_i3, e):
    global wsHistory
    global i3
    if not e.old:
        # Happens at initialization of i3?
        return
    if e.old.name.startswith("_") or e.current.name.startswith("_"):
        return
    oldWorkspace = actualWorkspace(e.old.name)
    currentWorkspace = actualWorkspace(e.current.name)
    # Delete the current workspace from the histories
    #~ for o in wsHistory:
    #~     try:
    #~         wsHistory[o].remove(currentWorkspace.name)
    #~     except ValueError:
    #~         pass

    if currentWorkspace is None or oldWorkspace is None:
        # oldWorkspace is None can happen if the old workspace is empty and
        # thus has been deleted.
        # Not sure how currentWorkspace can be None, but it did at least once
        return
    elif oldWorkspace.output != currentWorkspace.output:
        # Change of monitor, don't do anything
        return
    else:
        wsHistory[oldWorkspace.output].append(e.old.name)


def emptyWorkspaceEvent(my_i3, e):
    global wsHistory
    for o in wsHistory:
        try:
            wsHistory[o].remove(e.current.name)
        except ValueError:
            pass


def backAndForth(signalnum, handler):
    global i3
    global focusHistory

    currentWorkspace = actualWorkspace(i3.get_tree().find_focused().workspace().name)
    if currentWorkspace is None:
        return
    try:
        currentTargetIndex = 0
        while True:
            currentTargetIndex -= 1
            target = wsHistory[currentWorkspace.output][currentTargetIndex]
            targetIsShown = False
            for o in i3.get_outputs():
                if o.current_workspace and o.current_workspace == target:
                    targetIsShown = True
            if not targetIsShown:
                break
        gotoWorkspace(i3, target)
    except IndexError:
        pass


def main():
    global i3

    myPid = os.getpid()
    with open(pidFile, "w") as fp:
        print(myPid, file=fp)
    print(myPid)

    i3 = i3ipc.Connection()
    i3.on("workspace::focus", focusWorkspaceEvent)
    i3.on("workspace::empty", emptyWorkspaceEvent)
    signal.signal(signal.SIGUSR1, backAndForth)

    i3.main()


if __name__ == "__main__":
    main()
