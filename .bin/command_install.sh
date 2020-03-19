#!/bin/bash -eu

echo -------------------------------------------------
echo
echo                    bat
echo
echo -------------------------------------------------
if ! type "bat" > /dev/null 2>&1; then
    target="https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb"
    wget -c -P ~/ $target
    sudo apt install ~/bat_0.12.1_amd64.deb
    rm ~/bat_0.12.1_amd64.deb
    echo "alial cat=bat" >> ~/.zshrc
fi

echo -------------------------------------------------
echo
echo                    exa
echo
echo -------------------------------------------------
if ! type "exa" > /dev/null 2>&1; then
    sudo apt install curl -y
    curl https://sh.rustup.rs -sSf | sh
    wget -c -P ~/ https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip
    unzip ~/exa-linux-x86_64-0.9.0.zip
    sudo mv ~/exa-linux-x86_64 /bin/exa
    echo "alias ls='exa -g --time-style=long-iso'" >> ~/.zshrc
    echo "alias ll='ls -l'" >> ~/.zshrc
    echo "alias la='ls -al'" >> ~/.zshrc
fi

echo -------------------------------------------------
echo
echo                    xsel
echo
echo -------------------------------------------------
if ! type "xsel" > /dev/null 2>&1; then
    sudo apt install xsel -y
    echo "alias pbcopy='xsel --clipboard --input'" >> ~/.zshrc
fi

echo -------------------------------------------------
echo
echo                    tmux
echo
echo -------------------------------------------------
if ! type "tmux" > /dev/null 2>&1; then
    sudo apt install tmux -y
    cat >> ~/.zshrc << "EOF"
alias tmux='tmux -u2'

# tmuxの自動起動
count=`ps aux | grep tmux | grep -v grep | wc -l`
if test $count -eq 0; then
    echo `tmux`
elif test $count -eq 1; then
    echo `tmux a`
fi
EOF
fi