#!/usr/bin/env bash

BAT=$(pmset -g batt)
percent=$(echo "$BAT" | grep -Eo "\d+%" | cut -d% -f1)
isCharging=$(echo "$BAT" | grep "AC Power")

if [[ "$isCharging" != "" ]]; then
  case "$percent" in
    100) ICON="" ;;
    9[0-9]) ICON="" ;;
    8[0-9]) ICON="" ;;
    7[0-9]) ICON="" ;;
    6[0-9]) ICON="" ;;
    5[0-9]) ICON="" ;;
    4[0-9]) ICON="" ;;
    3[0-9]) ICON="" ;;
    2[0-9]) ICON="" ;;
    1[0-9]) ICON="" ;;
    [0-9]) ICON="" ;;
    *) ICON="" ;;
  esac
else
  case "$percent" in
    100) ICON="" ;;
    9[0-9]) ICON="" ;;
    8[0-9]) ICON="" ;;
    7[0-9]) ICON="" ;;
    6[0-9]) ICON="" ;;
    5[0-9]) ICON="" ;;
    4[0-9]) ICON="" ;;
    3[0-9]) ICON="" ;;
    2[0-9]) ICON="" ;;
    1[0-9]) ICON="" ;;
    [0-9]) ICON="" ;;
    *) ICON="" ;;
  esac
fi

sketchybar -m --set $NAME \
                        icon=$ICON \
                        label="$percent"%
