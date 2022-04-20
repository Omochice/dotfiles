#!/usr/bin/env bash

cat << EOF | osascript
tell application "System Preferences"
    reveal pane id "com.apple.preferences.Bluetooth"
    activate
end tell
EOF

