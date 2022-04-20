#!/usr/bin/env bash

bluetoothState=$(blueutil --power)

case "$bluetoothState" in
    "1" ) ICON=
          NUM=$(blueutil --paired --format json | jq ".[] | [select(.connected == true)]" | jq length) ;;
    "0" ) ICON= NUM=0 ;;
    * ) ICON=? NUM=? ;;
esac

sketchybar -m --set $NAME icon=$ICON label=$NUM
