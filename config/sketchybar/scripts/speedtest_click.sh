#!/usr/bin/env bash

cat << EOF | osascript
tell application "System Preferences"
    reveal pane id "com.apple.preference.network"
    activate
end tell
EOF

