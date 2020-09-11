#!/usr/bin/env bash -ue

function helpmsg() {
    command echo "usage: bash path/to/install.sh"
    command echo "        [-h]"
    command echo "        h: help"
    command echo "           show help message"
    exit 1
}

function link_to_homedir() {
    if [ ! -d "$HOME/.dotbackup" ]; then
        command echo "$HOME/.dotbackup not found. Auto Make it"
        command mkdir "$HOME/.dotbackup"
    fi

    command echo "link dotfiles..."
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    for f in ${dotdir}/.??*; do
        if [ $(basename $f) == ".git" -o $(basename $f) == ".gitignore" ]; then
            continue
        fi
        if [[ -L "$HOME/$(basename $f)" ]]; then
            command rm -f "$HOME/$(basename $f)"
        fi
        if [[ -e "$HOME/$(basename $f)" ]]; then
            command mv "$HOME/$(basename $f)" "$HOME/.dotbackup"
        fi
        command ln -snf $f $HOME
    done

    for config in "$dotdir/config/*"; do
        local dst="$HOME/.config/$(basename $conf)"
        if [ -d dst ]; then
            command rsync -a "$dst/" conf
            command rm -rf dst
        fi
        command ln -snf $conf $dst
    done
}

while getopts mh OPT; do
    case $OPT in
    h) helpmsg ;;
    \?) helpmsg ;;
    esac
done

link_to_homedir
git config --global include.path "~/.gitconfig_shared"
command echo -e "\e[1;36m Install completed!!!! \e[m"
