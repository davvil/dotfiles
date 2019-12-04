#!/usr/bin/env python

import i3ipc
import threading
import tkinter as tk

import time

MAXIMIZED_MARK = "M"
#MAXIMIZED_WS_PATTERN = "%s [M]"
MAXIMIZED_WS_PATTERN = "%s"
MAX_RETURN_WS_PATTERN = "_maximized_%s"
MAXIMIZED_PLACEHOLDER_PATTERN = "i3-maximize-%d"  # Fill with window id


def extract_original_ws_name(maximized_ws_name):
    # Must be in sync with MAXIMIZED_WS_PATTERN
    #return maximized_ws_name[:-4]
    return maximized_ws_name


syncSemaphore = threading.Semaphore(0)


def create_placeholder_window(title):
    """
    Adapted from https://github.com/Airblader/i3-sticky/blob/master/i3-sticky-open

    Opens a placeholder window for a sticky group.

    This utility opens a mostly empty window to be used as a placeholder container
    with i3-sticky. It takes an optional argument describing the group for which
    the container should be, defaulting to '1'. i3-sticky will pick up on this
    window and automatically mark it as a placeholder container for the
    corresponding group.

    (C) 2016 Ingo Bürk
    Licensed under The MIT License (https://opensource.org/licenses/MIT), see LICENSE.
    """
    win = tk.Tk(className="i3-maximize")
    win.title(title)

    label = "Maximize Placeholder"

    widget = tk.Text(win, height=1, borderwidth=0, highlightthickness=0)
    widget.place(relx=.5, rely=.5, anchor='c')

    widget.tag_configure('tag-center', justify='center')
    widget.insert('end', label, 'tag-center')

    syncSemaphore.release()

    win.mainloop()


def main():
    i3 = i3ipc.Connection()
    i3tree = i3.get_tree()

    focused_container = i3tree.find_focused()
    if not focused_container or focused_container.type != "con":
        return
    
    current_workspace = focused_container.workspace().name
    max_window_title = MAXIMIZED_PLACEHOLDER_PATTERN % focused_container.id
    if MAXIMIZED_MARK not in focused_container.marks:
        max_workspace = MAXIMIZED_WS_PATTERN % current_workspace
        max_return_workspace = MAX_RETURN_WS_PATTERN % current_workspace
        i3.command("rename workspace %s to %s" % (current_workspace, max_return_workspace))
        i3.command("workspace %s" % max_workspace)
        windowThread = threading.Thread(target=create_placeholder_window,
                                        args=(max_window_title,))
        windowThread.start()
        syncSemaphore.acquire()
        time.sleep(0.005)
        i3.command('[title="%s"] swap container with con_id %d' % (max_window_title, focused_container.id))
        i3.command('[con_id=%d] mark --add %s' % (focused_container.id, MAXIMIZED_MARK))
        windowThread.join()
    else:
        max_workspace = current_workspace
        original_workspace = extract_original_ws_name(max_workspace)
        max_return_workspace = MAX_RETURN_WS_PATTERN % original_workspace
        i3.command('[title="%s"] swap container with con_id %d' % (max_window_title, focused_container.id))
        i3.command('workspace %s' % max_return_workspace)
        i3.command('[title="%s"] kill' % max_window_title)
        i3.command('[con_id=%d] unmark %s' % (focused_container.id, MAXIMIZED_MARK))
        time.sleep(0.1)
        i3.command("rename workspace %s to %s" % (max_return_workspace, original_workspace))
        print("rename workspace %s to %s" % (max_return_workspace, original_workspace))


if __name__ == '__main__':
    main()
