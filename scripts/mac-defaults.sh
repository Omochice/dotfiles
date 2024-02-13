#!/usr/bin/env bash

set -ue

## dock {{{
# Set dock size
defaults write com.apple.dock tilesize -int 48
# Disable scaling
# defaults delete com.apple.dock magnification
# Show it left side
defaults write com.apple.dock orientation -string "left"
## }}}

## windowmanager {{{
defaults write com.apple.WindowManager HideDesktop -int 0
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0
## }}}

## Audio {{{
# Dont beep
defaults write "Apple Global Domain" com.apple.sound.beep.volume -int 0
## }}}

## trackpad {{{
# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
# Momentum scroll
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll -int 1
## }}}

## keyboard {{{
defaults write "Apple Global Domain" KeyRepeat -int 2
defaults write "Apple Global Domain" InitialKeyRepeat -int 25
## }}}

## menubar {{{
defaults write "Apple Global Domain" AppleMenuBarVisibleInFullscreen -int 0
defaults write "Apple Global Domain" "_HIHideMenuBar" -int 1
## }}}

## spotlight {{{
# Show spotlight on Mod-r
# NOTE: other shorcut is launched by karabiner | skhd
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

# finder {{{
## show pathbar
defaults write com.apple.finder ShowPathbar -bool true
# }}}

# vim:foldmethod=marker
