#!/usr/bin/bash

function vim_setup() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotdir=$(readlink -f ${script_dir}/..)

    command mkdir -p $dotdir/.vim/dein
    command curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh >$dotdir/.vim/dein/installer.sh
    command source $dotdir/.vim/dein/installer.sh

}
