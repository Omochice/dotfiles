#!/usr/bin/env bash

set -ue

# Disable S-Space
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>262144</integer></array><key>type</key><string>standard</string></dict></dict>"
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>786432</integer></array><key>type</key><string>standard</string></dict></dict>"


# Show spotlight on Mod-r
# NOTE: other shortcut is launched by karabiner | skhd
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
<dict>
  <key>enabled</key>
  <true/>
  <key>value</key>
  <dict>
    <key>parameters</key>
    <array>
      <integer>114</integer>
      <integer>15</integer>
      <integer>1048576</integer>
    </array>
  </dict>
</dict>
"
# Show only application
defaults write com.apple.Spotlight orderedItems -array \
  "{ enabled = 0; name = PDF; }" \
  "{ enabled = 0; name = 'MENU_SPOTLIGHT_SUGGESTIONS'; }" \
  "{ enabled = 0; name = BOOKMARKS; }" \
  "{ enabled = 1; name = APPLICATIONS; }" \
  "{ enabled = 0; name = 'EVENT_TODO'; }" \
  "{ enabled = 0; name = 'SYSTEM_PREFS'; }" \
  "{ enabled = 0; name = SPREADSHEETS; }" \
  "{ enabled = 0; name = 'MENU_OTHER'; }" \
  "{ enabled = 0; name = TIPS; }" \
  "{ enabled = 0; name = DIRECTORIES; }" \
  "{ enabled = 0; name = FONTS; }" \
  "{ enabled = 0; name = PRESENTATIONS; }" \
  "{ enabled = 0; name = MUSIC; }" \
  "{ enabled = 0; name = MOVIES; }" \
  "{ enabled = 0; name = MESSAGES; }" \
  "{ enabled = 0; name = IMAGES; }" \
  "{ enabled = 0; name = 'MENU_EXPRESSION'; }" \
  "{ enabled = 0; name = DOCUMENTS; }" \
  "{ enabled = 0; name = 'MENU_DEFINITION'; }" \
  "{ enabled = 0; name = 'MENU_CONVERSION'; }" \
  "{ enabled = 0; name = CONTACT; }"
## }}}

# vim:foldmethod=marker
