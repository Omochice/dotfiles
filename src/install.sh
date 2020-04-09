#!/usr/bin/env bash
set -ue

function helpmsg(){
    command echo "usage: bash path/to/install.sh"
    command echo "       [-m] [-h]"
    command echo "        m: mergin existing enviroment"
    command echo "           if you run this script in not new enviroment, add this option."
    command echo "        h: help"
    command echo "           show help message"
    exit 1
}


function position_verification(){
    if [[ "$HOME" == "$dotdir" ]];then
        command echo "\$HOME is dotfiles..."
        command echo "type 'git clone xxx' in your \$HOME and run this is dotfiles."
        exit 1
    fi
}

function merge_env(){
    command echo "merging existing dotfiles..."
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    for f in ${dotdir}/.??*; do
        [[ `basename $f` == ".git" ]] && continue
        if [[ ! -L "$HOME/`basename $f`" ]];then
            command cp -ru "$HOME/`basename $f`" "${dotdir}/"
        fi
    done
}

link_to_homedir() {
    command echo "backup old dotfiles..."
    if [ ! -d "$HOME/.dotbackup" ];then
        command echo "$HOME/.dotbackup not found. Auto Make it"
        command mkdir "$HOME/.dotbackup"
    fi

    command echo "link dotfiles..."
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)
    for f in ${dotdir}/.??*; do
        [[ `basename $f` == ".git" -o `basename $f` == ".gitignore"]] && continue
        if [[ -L "$HOME/`basename $f`" ]];then
            command rm -f "$HOME/`basename $f`"
        fi
        if [[ -e "$HOME/`basename $f`" ]];then
            command mv "$HOME/`basename $f`" "$HOME/.dotbackup"
        fi
        command ln -snf $f $HOME
    done
}


while getopts mh OPT
do 
    case $OPT in 
        m) merge_env;;  
        h) helpmsg ;;
        \?) helpmsg ;;  
    esac 
done   

link_to_homedir
git config --global include.path "~/.gitconfig_shared"
command echo -e "\e[1;36m Install completed!!!! \e[m"