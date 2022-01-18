#!/usr/bin/env bash

set -ue

HOST=8.8.8.8

echo -n "8.8.8.8 "
if ! ping=$(LANG=C ping -n -c 1 -W 1 $HOST); then
    echo "Unreachable"
else
    time=$(echo "$ping" | sed -rn "s/.*time=([0-9]+\.?[0-9]*) ms.*/\1/p")
    echo "${time}ms"
fi
