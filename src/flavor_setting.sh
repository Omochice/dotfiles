#!/bin/bash -ue


function run_by_flavor(){
    local flavor=$1
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    local flavordir="${script_dir}/flavor/${flavor}"

    if ! [ -e $flavordir ]; then
        echo "sorry. the flavor is not supported."
        exit 1
    fi
    source "${flavordir}/desktop_setting.sh"
}



function read_user_input() {
    local start=$1
    local end=$2
    read input
    if [ $input -ge $start ] && [ $input -le $end ]; then
        echo $input 
    else
        echo "Your input is not in range[$start, $end]."
        exit 1
    fi
}


function main() {
    echo "What is your Desktop environment ?"
    echo "    1) GNOME3"
    echo "    2) GNOME2"
    echo "    3) Xfce   "
    echo "    4) KDE    "
    echo "    5) LXDE   "
    echo "    6) i3   "
    printf "Input > "
    local flavor=$(read_user_input 1 6)
    echo
    local flavors=("gnome3" "gnome2" "xfce" "KDE" "LXDE" "i3")
    run_by_flavor ${flavors[$(($flavor - 1))]}
}


main
# ホームディレクトリを英語へ
LANG=C xdg-user-dirs-gtk-update
