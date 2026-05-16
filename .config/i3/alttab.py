#!/usr/bin/env python3

import signal
import os

import i3ipc

focusHistory = {}  # Indexed by workspace, contains pairs (prev, current)
i3 = None
pidFile = os.path.join(os.environ["HOME"], ".config", "i3", "alttab.pid")

def focusWindowEvent(my_i3, e):
    global focusHistory
    global i3
    windowId = e.container.id
    if e.container.floating == "user_on" or e.container.floating == "auto_on":
        return
    try:
        workspace = i3.get_tree().find_by_id(windowId).workspace().name
    except AttributeError:
        return
    hist = focusHistory.get(workspace)
    if hist:
        histCurrent = hist[1]
        if windowId != histCurrent:
            focusHistory[workspace] = (histCurrent, windowId)
    else:
        focusHistory[workspace] = (None, windowId)

def focusWindow(signalnum, handler):
    global i3
    global focusHistory

    workspace = i3.get_tree().find_focused().workspace().name
    hist = focusHistory.get(workspace)
    if hist is not None:
        prev = hist[0]
        if prev is not None:
            target_window = i3.get_tree().find_by_id(prev)
            if target_window:
                target_window.command("focus")

def main():
    global i3

    myPid = os.getpid()
    with open(pidFile, "w") as fp:
        print(myPid, file=fp)
    print(myPid)

    i3 = i3ipc.Connection()
    i3.on("window::focus", focusWindowEvent)
    signal.signal(signal.SIGUSR1, focusWindow)

    i3.main()

if __name__ == "__main__":
    main()
