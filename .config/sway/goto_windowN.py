#!/usr/bin/env python3

from argparse import ArgumentParser
import sys
import i3ipc


def traverse_tree(container):
  if not container.nodes:
    yield container
  else:
    for n in container.nodes:
      yield from traverse_tree(n)


def with_window(i3, window_index, action):
  focused = i3.get_tree().find_focused()
  if not focused:
    return
  ws_tree = focused.workspace()
  for n, w in enumerate(traverse_tree(ws_tree), 1):
    if n == window_index:
      action(i3, w)
      break


def focus(i3, w):
  w.command('focus')


def swap(i3, w):
  focused = i3.get_tree().find_focused()
  w.command("mark _swap")
  focused.command("swap container with mark _swap")


if __name__ == "__main__":
  argparser = ArgumentParser()
  argparser.add_argument(
      "--swap",
      help="Swap windows instead of focusing",
      action="store_true",
  )
  argparser.add_argument(
      "window_index",
      help="Window index to act on",
      type=int,
  )
  args = argparser.parse_args()

  i3 = i3ipc.Connection()
  action = swap if args.swap else focus
  with_window(i3, args.window_index, action)
