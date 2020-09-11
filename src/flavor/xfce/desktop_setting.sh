#!/bin/bash -ue

function main() {
    local work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local conf_dir="${work_dir}/conf"
    local dotdir=$(readlink -f ${work_dir}/../../..)

    # ターミナルの設定
    local dst="$HOME/.config/autostart/xfce-terminal.desktop"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/xfce-terminal.desktop" $dst

    local dst="$HOME/.config/xfce4/terminal/terminalrc"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/terminalrc" $dst

    # keyboard shortchut
    local dst="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/xfce4-keyboard-shortcuts.xml" $dst

    # appearance
    if ! [ -e ~/.theme ]; then
        mkdir ~/.theme
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    git clone https://github.com/rouchage/Hitori.git ~/.theme/
    sudo cp -r ~/.theme/Hitori /usr/share/themes
    xfconf-query -c xfwm4 -p /general/theme -s "Hitori"
}

main
