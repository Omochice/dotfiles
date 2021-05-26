#!/usr/bin/env bash -ue

function helpmsg() {
    command echo "usage: bash path/to/sync.sh"
    command echo "        [-h]"
    command echo "        h: help"
    command echo "           show help message"
    exit 1
}

function link_to_homedir() {
    local srcdir=$(readlink -f ${BASH_SOURCE[0]})
    local dotdir=$(dirname $(dirname ${srcdir}))

    for f in ${dotdir}/.??*; do
        local base=$(basename $f)
        if [ $base == ".git" -o $base == ".gitignore" -o $base == ".gitmodules" ]; then
            continue
        fi
        # Caution. if exists $f in $HOME, it replace with $f
        command ln -snf $f $HOME
    done
}

function link_to_config() {
    local srcdir=$(readlink -f ${BASH_SOURCE[0]})
    local confdir=$(dirname $(dirname ${srcdir}))/config
    echo $confdir
    for f in $(ls $confdir); do
        local base
        command ln -snf $f $HOME/.config/
    done
}

link_to_homedir
link_to_config

echo "done !!"
