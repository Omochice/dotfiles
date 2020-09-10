#!/bin/bash -ue

function main(){
    local work_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local conf_dir="${work_dir}/conf"
    local dotdir=$(readlink -f ${work_dir}/../../..)

    # ターミナルの設定
    local dst="${dotdir}/.config/autostart/xfce-terminal.desktop"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/xfce-terminal.desktop" "$(dirname $dst)"


    local dst="${dotdir}/.config/xfce4/terminal/teminalrc"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/terminalrc" "$(dirname $dst)"

    # keyboard shortchut
    local dst="${dotdir}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"
    if [ -e dst ]; then
        rm -f dst
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    ln -snf "${conf_dir}/xfce4-keyboard-shortcuts.xml" "$(dirname $dst)"

    # appearance
    if ! [ -e ~/.theme ]; then
        mkdir ~/.theme
    elif ! [ -e $(dirname $dst) ]; then
        mkdir -p $(dirname $dst)
    fi
    git clone https://github.com/rouchage/Hitori.git ~/.theme/
    xfconf-query -c xsettings -p /Net/ThemeName -s "Hitori"

}

main