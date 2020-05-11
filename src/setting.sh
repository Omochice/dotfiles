#!/bin/bash -ue

# capslockをctrlに
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

# # ctrl SpaceでIMEの切り替え
# echo 
# echo 
# echo 
# echo 
# echo 

# 日付表示の変更
gsettings set org.gnome.desktop.interface clock-show-date true

# ホームディレクトリを英語へ
LANG=C xdg-user-dirs-gtk-update