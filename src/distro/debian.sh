#!/bin/bash -eu

printf "zsh... "
if ! type "zsh" >/dev/null 2>&1; then
    printf " installing... "
    sudo apt install zsh -y >/dev/null
    printf "done.\n"
else
    printf " already installed.\n"
fi


printf "bat... "
if ! [ -x "$(command -v bat)" ] && ! [ -x "$(command -v batcat)" ]; then
    printf "installing... "
    wget -c -P ~/ "https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb" >/dev/null
    sudo apt -y install ~/bat_0.12.1_amd64.deb >/dev/null
    rm ~/bat_0.12.1_amd64.deb
    echo "done."
else
    echo "already installed."
fi

printf "curl ... "
if ! [ -x "$(command -v curl)" ]; then
    printf "installing... "
    sudo apt install -y curl >/dev/null
    echo "done."
else
    echo "already installed."
fi

printf "exa... "
if ! [ -x "$(command -v exa)" ]; then
    printf "installing... "
    curl https://sh.rustup.rs -sSf | sh
    wget -c -P ~/ https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip
    unzip ~/exa-linux-x86_64-0.9.0.zip -d ~
    rm ~/exa-linux-x86_64-0.9.0.zip
    sudo mv ~/exa-linux-x86_64 /bin/exa
    echo "done."
else
    echo "already installed."
fi

printf "xsel... "
if ! [ -x "$(command -v xsel)" ]; then
    printf "installing... "
    sudo apt install xsel -y >/dev/null
    echo "done."
else
    echo "already installed."
fi

printf "ripgrep... "
if ! [ -x "$(command -v ripgrep)" ]; then
    printf "installing... "
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep_12.0.1_amd64.deb ~/
    sudo apt install -y ~/ripgrep_12.0.1_amd64.deb >/dev/null
    rm ~/ripgrep_12.0.1_amd64.deb
    echo "done."
else
    echo "already installed."
fi

printf "peco... "
if ! [ -x "$(command -v peco)" ]; then
    printf "installing... "
    sudo apt install peco -y >/dev/null
    echo "done."
else
    echo "already installed."
fi

printf "tmux... "
if ! [ -x "$(command -v tmux)" ]; then
    printf "installing... "
    sudo apt install tmux -y >/dev/null
    echo "done."
else
    echo "already installed."
fi

printf "anyenv... "
if ! [ -x "$(command -v anyenv)" ]; then
    printf "installing... "
    git clone https://github.com/anyenv/anyenv ~/.anyenv >/dev/null
    anyenv install --init
    echo "done."
else
    echo "already installed."
fi

printf "git(latest)... "
if ! [ -x "$(command -v git)" ]; then
    printf "installing... "
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update >/dev/null
    sudo apt install git >/dev/null
    echo "done."
else
    echo "already installed."
fi

printf "VScode... "
if ! [ -x "$(command -v code)" ]; then
    printf "installing... "
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt install apt-transport-https code
    rm microsoft.gpg
    echo "done."
else
    echo "already installed."
fi

printf "vivaldi... "
if ! [ -x "$(command -v vivaldi)" ]; then
    printf "installing... "
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main'
    sudo apt update && sudo apt install vivaldi-stable
    echo "done."
else
    echo "already installed."
fi

printf "fish shell ..."
if ! [ -x "$(command -v fish)" ]; then
    printf "installing... "
    sudo apt install -y fish
    echo "done"
fi



