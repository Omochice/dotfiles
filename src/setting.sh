#!/bin/bash -ue


function run_setting(flavor){
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    local distdir="${script_dir}/dist/${flavor}"

    source "${distdir}/desktop_setting.sh"
    ln -snf "${distdir}/${flavor}-terminal.desktop" "${dotdir}/.config/autostart/"
}

function read_user_env(){
    printf "input number > "
    read input
    if [ -z $input ]; then
        read_user_env
    elif [ "$input" = "1" ] ; then
        run_setting("gnome3")
    elif [ "$input" = "2" ] ; then
        run_setting("gnome2")
    elif [ "$input" = "3" ] ; then
        run_setting("xfce")
    elif [ "$input" = "4" ] ; then
        run_setting("KDE")
    elif [ "$input" = "5" ] ; then
        run_setting("LXDE")
    else
        echo "If the list have not got your desktop environment,"
        echo "Please type \"Ctrl-C\" to exit this script."
        read_user_env
    fi
}


function main(){
    echo "What is your Desktop environment ?"
    echo "    1) GNOME3 (Ubuntu)"
    echo "    2) GNOME2 (Ubuntu-MATE)"
    echo "    3) Xfce   (Xubuntu)"
    echo "    4) KDE    (Kubuntu)"
    echo "    5) LXDE   (Lubuntu)"
    read_user_env
}



main


# ホームディレクトリを英語へ
LANG=C xdg-user-dirs-gtk-update

# VPNの設定
sudo apt install openconnect network-manager-openconnect network-manager-openconnect-gnome
sudo systemctl restart network-manager.service
