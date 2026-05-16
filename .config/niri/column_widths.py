#!/usr/bin/env python3

from argparse import ArgumentParser
import json
import os
import subprocess
import sys
import time
from pprint import pprint


events_to_monitor = [
    "WorkspacesChanged",
    "WorkspaceActivated",
    "WorkspaceActiveWindowChanged",
    "WindowsChanged",
    "WindowOpenedOrChanged",
    "WindowClosed",
    "WindowFocusTimestampChanged",
    "WindowLayoutsChanged",
]


def niri_cmd(command: str, full_output=False):
  subp_run = subprocess.run(
      ["niri", "msg", "--json"] + command.split(),
      capture_output=True,
      text=True,
  )
  if subp_run.stderr:
    print(subp_run.stderr, file=sys.stderr)

  if full_output:
    return subp_run
  else:
    if subp_run.stdout:
      return json.loads(subp_run.stdout)
    else:
      return ""


def get_column_for_window(w):
  if w["layout"]["pos_in_scrolling_layout"] is not None:
    column = w["layout"]["pos_in_scrolling_layout"][0]
  else:
    column = None
  return column


def get_ws_pos(wss, active_ws):
  before = 0
  after = 0
  for ws in wss:
    if ws["idx"] < active_ws["idx"]:
      before += 1
    elif ws["idx"] > active_ws["idx"]:
      after += 1
  return f"↑{before} ↓{after}"


def get_columns(active_ws):
  window_list = niri_cmd("windows")
  focused_window = [w for w in window_list if w["is_focused"]]
  if focused_window and focused_window[0]["workspace_id"] == active_ws["id"]:
    focused_column = get_column_for_window(focused_window[0])
  else:
    focused_column = None
  window_list = [w for w in window_list if w["workspace_id"] == active_ws["id"]]
  cols = set()
  for w in window_list:
    column = get_column_for_window(w)
    if column is not None:
      cols.add(column)
  repr_str = []
  for c in cols:
    if focused_column and c == focused_column:
      repr_str.append("◎")
    else:
      repr_str.append("·")
  return " ".join(repr_str)


def generate_output():
  workspaces = niri_cmd("workspaces")
  my_wss = [ws for ws in workspaces if ws["output"] == MY_OUTPUT]
  active_ws = [ws for ws in my_wss if ws["is_active"]][0]

  output = f"{get_ws_pos(my_wss, active_ws)} {get_columns(active_ws)}"
  return output


def adjust_columns(n_columns = None):
  focused_ws = [ws for ws in niri_cmd("workspaces")
                if ws["is_focused"]][0]
  ws_windows = [w for w in niri_cmd("windows")
                if w["workspace_id"] == focused_ws["id"]]

  if not n_columns:
    columns = set(
        w["layout"]["pos_in_scrolling_layout"][0]
        for w in ws_windows
        if w["layout"]["pos_in_scrolling_layout"]
    )
    n_columns = len(columns)

  column_width_perc = f"{1 / n_columns * 100:.1f}%"

  # set-column-width acts on the focused column, so we'll go through
  # all the columns and resize them
  resized_columns = set()
  focused_window = niri_cmd("focused-window")
  for w in ws_windows:
    if w["layout"]["pos_in_scrolling_layout"]:
      column = w["layout"]["pos_in_scrolling_layout"][0]
      if column not in resized_columns:
        niri_cmd(f"action focus-window --id {w["id"]}")
        niri_cmd(f"action set-column-width {column_width_perc}")
        resized_columns.add(column)

  # Give time for the animations to settle, so
  # that we have a centered view.
  time.sleep(0.1)
  if focused_window:
    niri_cmd(f"action focus-window --id {focused_window["id"]}")


def main():
  argparser = ArgumentParser()
  argparser.add_argument("n_columns", type=int, nargs="?")
  args = argparser.parse_args()
  adjust_columns(args.n_columns)


if __name__ == "__main__":
  main()
