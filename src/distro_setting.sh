#!/bin/bash -ue

function run_by_distro() {
    local distro=$1
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    local distro_script="${script_dir}/distro/${distro}.sh"

    if ! [ -e $distro_script ]; then
        echo "sorry. the distro is not supported."
    fi
    source $distro_script
}

function read_user_input() {
    local start=$1
    local end=$2
    if [ $input -ge $start ] && [ $input -le $end ]; then
        echo $input 
    else
        echo "Your input is not in range[$start, $end]."
        exit 1
    fi

function main() {
    echo "What is your Distro\'s package manager ?"
    echo "    1) apt (Debian, etc)"
    echo "    2) yum (Red Hat, etc)"
    echo "    3) pacman (Arch, etc)"
    printf "Input > "
    local distro=$(read_user_input 1 3)
    echo 
    local distros=("debian" "RedHat" "arch")
    run_by_distro ${distros[$distro]}
}

function other_settings() {
    LANG=C xdg-user-dirs-gtk-update
    sudo sed -i "s/XKBOPTIONS.*/XKBOPTIONS=\"ctrl:nocaps\"/" /etc/default/keyboard
}

main


