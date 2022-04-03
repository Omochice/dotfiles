#!/usr/bin/env bash

set -u



function helpmsg() {
    command echo "usage: bash path/to/sync.sh"
    command echo "        [-h]"
    command echo "        h: help"
    command echo "           show help message"
    exit 1
}

# from https://qiita.com/ko1nksm/items/873cfb9c6ceb6ef32ec9
function readlinkf_posix() {
  [ ${1:+x} ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD" "${OLDPWD:-}"
  CDPATH="" cd -P "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ "$p" = "$4" ] || { CDPATH="" cd -P "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3" "$p"; p=$(ls -dl "$p") || break; p=${p#*" $4 -> "}
  done 2>/dev/null; cd -L "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
}

function link_to_homedir() {
    local backupdir=$HOME/.dotbackup
    if [[ ! -e $backupdir ]]; then
        eommand echo "$backupdir is not exists. auto make it."
        command mkdir $backupdir
    fi

    for f in ${dotdir}/.??*; do
        local base=$(basename $f)
        local dst=$HOME/$base
        if [ $base = ".git" ] || [ $base = ".gitignore" ] || [ $base = ".gitmodules" ]; then
            continue
        fi

        if [[ -e $dst ]]; then
            if [[ $(readlink $dst) == $f ]]; then
                continue
            else
                command echo "[move] $dst -> $backupdir/$base"
                command mv $dst $backupdir/$base
                command ln -snf $f $HOME
            fi
	else
                command ln -snf $f $HOME

        fi
    done
}

function link_to_config() {
    local confdir=${dotdir}/config
    for f in $(ls $confdir/); do
        local src=$confdir/$f
        local dst=$HOME/.config/$f
        command ln -snf $src $dst
    done
}

function link_profile() {
    local srcfile=${dotdir}/profile
    if [[ $(basename $SHELL) = bash ]]; then
        command ln -snf $srcfile $HOME/.profile
    elif [[ $(basename $SHELL) = zsh ]]; then
        command ln -snf $srcfile $HOME/.zprofile
    fi
}

dotdir=$(readlinkf_posix $(dirname $(dirname $0)))
echo $dotdir
ls="ls"
if [[ $(uname) = Darwin ]]; then
    ls="gls"
fi

link_to_homedir
link_to_config
link_profile

echo "done !!"
