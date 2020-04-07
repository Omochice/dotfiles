#!/bin/bash -eu

echo -------------------------------------------------
echo
echo                    zsh
echo
echo -------------------------------------------------
if ! type "zsh" > /dev/null 2>&1; then
    sudo apt install zsh
fi

local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for rcfile in ${script_dir}.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s /bin/zsh
git clone https://github.com/powerline/fonts.git --depth=1
bash ./fonts/install.sh && rm -rf ./fonts


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
    # echo "alias cat='bat'" >> ~/.zshrc
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
    rm ~/exa-linux-x86_64-0.9.0.zip
    sudo mv ~/exa-linux-x86_64 /bin/exa
    # echo "alias ls='exa -g --time-style=long-iso'" >> ~/.zshrc
    # echo "alias ll='ls -l'" >> ~/.zshrc
    # echo "alias la='ls -al'" >> ~/.zshrc
fi

echo -------------------------------------------------
echo
echo                    xsel
echo
echo -------------------------------------------------
if ! type "xsel" > /dev/null 2>&1; then
    sudo apt install xsel -y
    # echo "alias pbcopy='xsel --clipboard --input'" >> ~/.zshrc
fi

echo -------------------------------------------------
echo
echo                    tmux
echo
echo -------------------------------------------------
if ! type "tmux" > /dev/null 2>&1; then
    sudo apt install tmux -y
#     cat >> ~/.zshrc << "EOF"
# alias tmux='tmux -u2'

# # tmuxの自動起動
# count=`ps aux | grep tmux | grep -v grep | wc -l`
# if test $count -eq 0; then
#     echo `tmux`
# elif test $count -eq 1; then
#     echo `tmux a`
# fi
# EOF
fi

echo -------------------------------------------------
echo
echo "git (lastest)"
echo
echo -------------------------------------------------

sudo add-apt-repository ppa:git-core/ppa 
sudo apt update
sudo apt install git 

echo -------------------------------------------------
echo
echo "chrome (stable)"
echo
echo -------------------------------------------------

if ! type "google-chrome" > /dev/null 2>&1; then
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo apt update
    sudo apt install google-chrome-stable
fi

echo -------------------------------------------------
echo
echo "VS code"
echo
echo -------------------------------------------------


if ! type "code" > /dev/null 2>&1; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt install apt-transport-https code
    rm microsoft.gpg
fi

echo -------------------------------------------------
echo
echo "Vivaldi"
echo
echo -------------------------------------------------


if ! type "vivaldi" > /dev/null 2>&1; then
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    sudo add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main' 
    sudo apt update && sudo apt install vivaldi-stable
fi




