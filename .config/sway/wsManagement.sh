#!/bin/bash

cd $(dirname $0)

source rofiMonitor.sh

monitor=`get_monitor`

ROFI=$HOME/rofi/bin/rofi

case $1 in
  goto)
    ~/.config/sway/gotoWorkspace.py $(~/.config/sway/getWorkspaces-icons.py | $ROFI -show-icons -monitor $monitor -dmenu -auto-select -matching regex -filter '^' -p ' Change to WS:' -fullscreen -padding 250 -me-select-entry '' -me-accept-entry 'MousePrimary' -fi -theme-str 'listview { lines: 20; }')
    ;;
  create)
    ~/.config/sway/gotoWorkspace.py $(~/.config/sway/getWorkspaces-icons.py | $ROFI -show-icons -monitor $monitor -dmenu -p ' Create WS:' -fullscreen -padding 250)
    ;;
  move)
    swaymsg move container to workspace $(~/.config/sway/getWorkspaces-icons.py | $ROFI -show-icons -monitor $monitor -dmenu -auto-select -matching regex -m -2 -filter '^' -p ' Move window to WS:' -theme-str "* { font: \"RobotoMono Nerd Font 16\"; } window {`./rofiOnWindow.py` border-radius: 0px; }")
    ;;
  moveNew)
    swaymsg move container to workspace $(~/.config/sway/getWorkspaces-icons.py | $ROFI -show-icons -monitor $monitor -dmenu -matching regex -m -2 -p ' Move window to new WS:' -theme-str "* { font: \"RobotoMono Nerd Font 16\"; } window {`./rofiOnWindow.py` border-radius: 0px; }")
    ;;
  *)
    exit 0;
    ;;
esac

