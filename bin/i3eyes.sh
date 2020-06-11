#!/bin/bash

source $HOME/.environment.sh

xeyesSize=36x23

if [[ $1 == "run" ]]; then
    kill=false
    run=true
elif [[ $1 == "kill" ]]; then
    kill=true
    run=false
elif [[ $1 == "toggle" ]]; then
    if pgrep xeyes > /dev/null; then
        kill=true
        run=false
    else
        run=true
        kill=false
    fi
fi

function move_and_unmap() {
    regex=$1
    y=$2
    xdotool search --class $regex set_window --overrideredirect 1 windowunmap --sync
    xdotool search --class $regex windowmap windowmove 0 $y windowraise
}

if $kill; then
    pkill xeyes
fi

if $run; then
    externalMonitor=`externalMonitor.sh`
    if [[ -n $externalMonitor ]]; then
        xeyes-bigMonitor +shape -bg black -geometry $xeyesSize &
        xeyes +shape -bg black -geometry $xeyesSize &
        eDP1offset=$(xrandr | sed -n -r '/eDP-1/s#.*[0-9]+x[0-9]+\+[0-9]+\+([0-9]+).*$#\1#p')
        sleep 0.1
        move_and_unmap '^XEyes$' $eDP1offset
        move_and_unmap '^XEyes-bigMonitor$' 0
    else
        xeyes +shape -bg black -geometry $xeyesSize &
        sleep 0.1
        move_and_unmap '^XEyes$' 0
    fi
fi
