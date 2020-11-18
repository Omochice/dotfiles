#!/usr/bin/bash

function main(){
    command curl -sL git.io/fisher | source && fisher install jorgebucaran/fisher
    local plugins=$(dirname $0/plugins.txt)
    echo "fisher is installed."
    echo "Type \`fisher add < $plugins \`"
}

main

