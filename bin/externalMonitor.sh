#!/bin/bash

# Detect if we have an external monitor connected (not cloned!) and return its name

externalMonitor=`xrasengan -lac | grep -v eDP-1`

if [[ -n $externalMonitor ]]; then
    # Try to detect if we are cloning
    clone=`xrandr | grep eDP-1 | grep +0+0`
    if ! [[ -n $clone ]]; then
        echo $externalMonitor
    fi
fi
