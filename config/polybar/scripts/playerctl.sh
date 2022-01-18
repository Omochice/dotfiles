#!/usr/bin/env bash

set -ue

status=$(playerctl status 2>/dev/null)

case "$status" in
    "Playing")
        echo "$(playerctl metadata title) "
        ;;
    "Paused")
        echo "$(playerctl metadata title) "
        ;;
    *)
        echo
esac
