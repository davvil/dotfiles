#!/usr/bin/env python3

from argparse import ArgumentParser

from niri_ipc import niri_cmd


def main():
  argparser = ArgumentParser()
  argparser.add_argument("direction", type=int, default=1,
                         nargs="?",
                         help="Direction to swap: +1 or -1")
  args = argparser.parse_args()

  dir = args.direction
  wss = niri_cmd("workspaces")
  active_wss = [ws for ws in wss if ws["is_active"]]
  n_monitors = len(active_wss)
  if n_monitors == 1:
    return
  niri_cmd("action do-screen-transition")
  for i in range(n_monitors):
    ws = active_wss[i]
    next_ws = active_wss[(i + dir) % n_monitors]
    niri_cmd(f"action move-workspace-to-monitor --reference {ws['name']} {next_ws['output']}")
    niri_cmd(f"action focus-workspace {ws['name']}")
  for ws in active_wss:
    if ws["is_focused"]:
      niri_cmd(f"action focus-workspace {ws['name']}")
      break


if __name__ == "__main__":
  main()
