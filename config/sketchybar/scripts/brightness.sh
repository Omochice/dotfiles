#!/usr/bin/env bash

set -ue

brightLevel=$(~/Tools/brightness/brightness -l | grep brightness | cut -d" " -f4)

sketchybar -m --set $NAME label="$BUTTON"
