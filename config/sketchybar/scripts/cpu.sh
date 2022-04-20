#!/usr/bin/env bash

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | rg -v $(whoami) | sd "[^ 0-9\.]" "\n" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
# The first line is "%CPU USER", it is unnecessary to get sum. so skip it by using secondary rg
CPU_USER=$(echo "$CPU_INFO" | rg $(whoami) | rg "^\s*[\d\.]" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

# echo "$CPU_PERCENT"%

sketchybar -m --set $NAME label="$CPU_PERCENT"%
