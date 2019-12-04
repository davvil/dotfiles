#!/usr/bin/env python3

import signal
import os

import i3ipc

wsHistory = {}  # Indexed by monitor
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
    #~ print(e.old.name, "->", e.current.name)
    #~ if e.old.name == "__i3_scratch":
    if e.old.name.startswith("_") or e.current.name.startswith("_"):
        #~ print("Ignored")
        return
    oldWorkspace = actualWorkspace(e.old.name)
    currentWorkspace = actualWorkspace(e.current.name)
    # Detect if we just changed the monitor
    if currentWorkspace is None:  # Not sure how this can happen, but it did at least once
        return
    if oldWorkspace is None:
        # Can happen if the old workspace is empty and thus has been deleted.
        # Assume we were in the same output
        wsHistory[currentWorkspace.output] = e.old.name
    elif oldWorkspace.output != currentWorkspace.output:
        return
    else:
        wsHistory[oldWorkspace.output] = oldWorkspace.name


def backAndForth(signalnum, handler):
    global i3
    global focusHistory

    currentWorkspace = actualWorkspace(i3.get_tree().find_focused().workspace().name)
    if currentWorkspace is None:
        return
    #~ print("Current:", currentWorkspace.output)
    target = wsHistory.get(currentWorkspace.output)
    if target is None:
        return
    #~ print("Target:", target)
    i3.command("workspace %s" % target)


def main():
    global i3

    myPid = os.getpid()
    with open(pidFile, "w") as fp:
        print(myPid, file=fp)
    print(myPid)

    i3 = i3ipc.Connection()
    i3.on("workspace::focus", focusWorkspaceEvent)
    signal.signal(signal.SIGUSR1, backAndForth)

    i3.main()


if __name__ == "__main__":
    main()
