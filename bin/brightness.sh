#!/bin/bash

SYSPATH=/sys/class/backlight/intel_backlight/
MIN_VALUE=100
MAX_VALUE=`cat $SYSPATH/max_brightness`
CURRENT_VALUE=`cat $SYSPATH/brightness`

N_STEPS=20
STEP_SIZE=$(( (MAX_VALUE - MIN_VALUE) / $N_STEPS))

if ! [[ -n $1 ]]; then
    echo $CURRENT_VALUE
    exit 0
elif [[ $1 == "inc" ]]; then
    NEW_VALUE=$((CURRENT_VALUE + STEP_SIZE))
    if [[ $NEW_VALUE -gt $MAX_VALUE ]]; then
        NEW_VALUE=$MAX_VALUE
    fi
elif [[ $1 == "dec" ]]; then
    NEW_VALUE=$((CURRENT_VALUE - STEP_SIZE))
    if [[ $NEW_VALUE -lt $MIN_VALUE ]]; then
        NEW_VALUE=$MIN_VALUE
    fi
else
    echo "Unknown command: $1" >& /dev/stderr
    exit 1
fi

echo $NEW_VALUE > $SYSPATH/brightness
echo $MIN_VALUE $MAX_VALUE $NEW_VALUE
brightness_dunst $MIN_VALUE $MAX_VALUE $NEW_VALUE
