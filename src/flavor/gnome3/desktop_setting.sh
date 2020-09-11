#!/bin/bash -ue

# capslockをctrlに
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

# 日付表示の変更
gsettings set org.gnome.desktop.interface clock-show-date true
