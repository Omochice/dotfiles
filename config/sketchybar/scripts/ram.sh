#!/usr/bin/env bash

sketchybar -m --set $NAME label=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5"%"}')
