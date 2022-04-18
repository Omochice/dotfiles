#!/usr/bin/env bash

speed=$(networkQuality -c)

download=$(echo $speed | jq 'if .dl_throughput then .["dl_throughput"] / 1024 / 1024 else 0 end' | sed -e "s/\(\.[0-9]\{0,3\}\)[0-9]*/\1/g")
upload=$(echo $speed | jq 'if .ul_throughput then .["ul_throughput"] / 1024 / 1024 else 0 end' | sed -e "s/\(\.[0-9]\{0,3\}\)[0-9]*/\1/g")

if [[ "$download" = "null" ]] || [[ "$upload" = "null" ]] ; then
    exit 1
fi

sketchybar -m --set $NAME label="${download} Mbps/${upload} Mbps"
