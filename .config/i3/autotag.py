#!/usr/bin/env python3

import i3ipc

def traverseTree(container):
    if not container.nodes:
        yield container
    else:
        for n in container.nodes:
            yield from traverseTree(n)

def tagTree(i3, e):
    wsTree = i3.get_tree().find_focused().workspace()
    nextMark = 1
    for w in traverseTree(wsTree):
        w.command('mark --add {}'.format(nextMark))
        nextMark += 1
    for m in range(nextMark, 10):
        i3.command('unmark {}'.format(m))

if __name__ == "__main__":
    i3 = i3ipc.Connection()
    i3.on("window::new", tagTree)
    i3.on("window::close", tagTree)
    i3.on("window::move", tagTree)
    i3.on("workspace::focus", tagTree)

    i3.main()
