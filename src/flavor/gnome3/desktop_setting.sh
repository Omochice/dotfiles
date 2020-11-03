#!/bin/bash -ue

# capslockをctrlに
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

# 日付表示の変更
gsettings set org.gnome.desktop.interface clock-show-date true

function main() {
    local work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local conf_dir="${work_dir}/conf"
    local dotdir=$(readlink -f ${work_dir}/../../..)

    local dst="$HOME/.config/autostart/gnome3-terminal.desktop"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/gnome3-terminal.desktop"

}
