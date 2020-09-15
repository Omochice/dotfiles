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

function main() {
    local -A distros
    PS3="Input your Distro\' package manager > "
    local pm="apt yum pacman"
    select distro in $pm; do
        break
    done
    declare -A distros
    distros=(["apt"]="debian" ["yum"]="redhat" ["pacman"]="arch")

    run_by_distro ${distros[$distro]}
}

function other_settings() {
    LANG=C xdg-user-dirs-gtk-update
    sudo sed -i "s/XKBOPTIONS.*/XKBOPTIONS=\"ctrl:nocaps\"/" /etc/default/keyboard
    wget -O - https://github.com/shvchk/poly-dark/raw/master/install.sh | bash
}

main
other_settings
