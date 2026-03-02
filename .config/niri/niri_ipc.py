#!/usr/bin/env python3

import socket
import json
import os
import subprocess
import sys


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


class NiriIPC:
  def __init__(self, socket_path=None):
    self.socket_path = socket_path or os.environ.get("NIRI_SOCKET")
    if not self.socket_path:
      raise RuntimeError("NIRI_SOCKET environment variable not set.")

  def request(self, command_dict):
    """Sends a JSON request and returns the parsed JSON response."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
      s.connect(self.socket_path)

      # 1. Encode to JSON and ensure it ends with a newline
      payload = json.dumps(command_dict) + "\n"
      s.sendall(payload.encode("utf-8"))

      # 2. Read the response until the newline
      # Using makefile() allows us to use readline() easily
      with s.makefile("r", encoding="utf-8") as response_file:
        line = response_file.readline()
        if not line:
          return None
        return json.loads(line)


# Example usage:
if __name__ == "__main__":
  niri = NiriIPC()

  # Check version
  print("Version:", niri.request({"Version": None}))
