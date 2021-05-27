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
    local backupdir=$HOME/.dotbackup
    if [[ ! -e $backupdir ]]; then
        command echo "$backupdir is not exists. auto make it."
        command mkdir $backupdir
    fi

    for f in ${dotdir}/.??*; do
        local base=$(basename $f)
        local dst=$HOME/$base
        if [ $base == ".git" -o $base == ".gitignore" -o $base == ".gitmodules" ]; then
            continue
        fi

        if [[ -e $dst ]]; then
            if [[ $(readlink -f $dst) == $f ]]; then
                continue
            else
                command echo "[move] $dst -> $backupdir/$base"
                command mv $dst $backupdir/$base
                command ln -snf $f $HOME
            fi

        fi
    done
}

function link_to_config() {
    local srcdir=$(readlink -f ${BASH_SOURCE[0]})
    local confdir=$(dirname $(dirname ${srcdir}))/config
    for f in $(ls $confdir/); do
        local src=$confdir/$f
        local dst=$HOME/.config/$f
        command ln -snf $src $dst
    done
}

link_to_homedir
link_to_config

echo "done !!"
