#!/usr/bin/env bash

step=0.05

case "$BUTTON" in
    "right" ) operator="-" ;;
    "left" ) operator="+" ;;
esac

brightLevel=$(~/Tools/brightness/brightness -l | grep brightness | cut -d" " -f4)

next=$(echo $brightLevel $operator 0.05 | bc | sed -e "s/0*\$//g")
if [[ $(echo "$next < 0" | bc) -eq 1 ]]; then
    next=0
elif [[ $(echo "$next > 1" | bc) -eq 1 ]]; then
    next=1
fi

percent=$(echo "$next * 100" | bc | sed -E "s/\.[0-9]+//g")

case "$percent" in
    100) ICON="";;
    9[0-9]) ICON="";;
    8[0-9]) ICON="";;
    7[0-9]) ICON="";;
    6[0-9]) ICON="";;
    5[0-9]) ICON="";;
    4[0-9]) ICON="";;
    3[0-9]) ICON="";;
    2[0-9]) ICON="";;
    1[0-9]) ICON="";;
    [0-9]) ICON="";;
    *) ICON=""
esac

~/Tools/brightness/brightness -m $next
sketchybar -m --set $NAME label="$percent"% \
                          icon="$ICON"
