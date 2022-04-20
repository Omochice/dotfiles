#!/usr/bin/env bash

set -ue

case "$SENDER" in
    "mouse.entered" ) sketchybar -m --set $NAME label="$(date '+%m/%d')" ;;
    * ) sketchybar -m --set $NAME label="$(date '+%H:%M')" ;;
esac
