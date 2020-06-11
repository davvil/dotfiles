#!/bin/bash

source $HOME/.environment.sh

internal=eDP-1
external=`xrasengan -lc | grep -v $internal`
maxTries=5
sleepWait=3

function countModes() {
    xrandr | awk -v screen=$1 '
        inBlock {if (substr($0, 1, 1) != " " ) exit; else count+=1; }
        $0~screen {inBlock = 1;}
        END { print count; }'
}

function msg() {
    dunstify -r 200 -- "$*"
    echo "$*" 1>& 2
}

case $1 in
    Dual)
        if [[ -n $external ]]; then
            nTries=0
            looksOk=false
            while (! $looksOk) && [[ $nTries < $maxTries ]]; do
                ((nTries++))
                nModes=`countModes $external`
                [[ $nModes -le 1 ]] || looksOk=true
                if (! $looksOk) && [[ $nTries < $maxTries ]]; then
                    msg "Number of modes for $external seems too low, retrying in $sleepWait seconds ($nTries)."
                    sleep $sleepWait
                fi
            done
            if $looksOk; then
                xrandr --output $internal --primary --auto --output $external --above $internal --auto
            else
                msg "$external doesn't seem to be reacting"
            fi
        else
            msg "No external display detected." 1>&2
        fi
        ;;
    Internal)
        xrandr --output $internal --primary --auto --output DP-1 --off --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off --output DP-2 --off --output HDMI-1 --off --output HDMI-2 --off
        ;;
    Clone)
        targetRes=$(xrandr | $HOME/bin/monitorsFindCommonModes.py)
        xrandr --output $internal --primary --mode $targetRes --output $external --mode $targetRes --same-as $internal
        ;;
    Clone_1920x1080)
        xrandr --output $internal --primary --auto --output $external --mode 1920x1080 --same-as $internal
        ;;
    List)
        echo Dual
        echo Internal
        echo Clone
        echo Clone_1920x1080
        exit 0
        ;;
    *)
        echo "Argument \"$1\" not recognized" 1>&2
        exit 1
        ;;
esac

feh --bg-max $HOME/wallpapers/apod_background_1920x1080.jpg $HOME/wallpapers/apod_background_3440x1440.jpg
i3eyes.sh
$HOME/.config/polybar/smart-launch.sh
