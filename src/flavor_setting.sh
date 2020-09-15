#!/bin/bash -ue

function run_by_flavor() {
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

function main() {
    PS3="Input your Desktop Environment > "
    local de="gnome3 gnome2 xfce kde lxde i3"
    select flavor in de; do
        break
    done
    run_by_flavor ${flavor}
}

main
