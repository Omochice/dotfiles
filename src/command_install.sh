#!/bin/bash -eu

echo -------------------------------------------------
echo
echo                    zsh(zprezto) 
echo
echo -------------------------------------------------
if ! type "zsh" > /dev/null 2>&1; then
    sudo apt install zsh
fi

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
for rcfile in $(ls -d $HOME/dotfiles/zshell/z*) ; do
    rm -rf "${ZDOTDIR:-$HOME}/.$(basename $rcfile)"
    ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.$(basename $rcfile)"
done
chsh -s /bin/zsh
git clone https://github.com/powerline/fonts.git ~/fonts --depth=1
bash ~/fonts/install.sh && rm -rf ~/fonts


echo -------------------------------------------------
echo
echo                    bat
echo
echo -------------------------------------------------
if ! type "bat" > /dev/null 2>&1; then
    if ! type "batcat" > /dev/null 2>&1; then # orの書き方がわからない
        target="https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb"
        wget -c -P ~/ $target
        sudo apt install ~/bat_0.12.1_amd64.deb
        rm ~/bat_0.12.1_amd64.deb
        # echo "alias cat='bat'" >> ~/.zshrc
    fi
fi

echo -------------------------------------------------
echo
echo                    exa
echo
echo -------------------------------------------------
if ! type "exa" > /dev/null 2>&1; then
    if ! type "curl" > /dev/null 2>&1; then
        sudo apt install curl -y
    fi
    curl https://sh.rustup.rs -sSf | sh
    wget -c -P ~/ https://github.com/ogham/exa/releases/download/v0.9.0/exa-linux-x86_64-0.9.0.zip
    unzip ~/exa-linux-x86_64-0.9.0.zip -d ~
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
echo                    ripgrep
echo
echo -------------------------------------------------
if ! type "rg" > /dev/null 2>&1; then
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep_12.0.1_amd64.deb
    sudo dpkg -i ripgrep_12.0.1_amd64.deb
    rm ripgrep_12.0.1_amd64.deb
fi


echo -------------------------------------------------
echo
echo                    peco
echo
echo -------------------------------------------------
if ! type "peco" > /dev/null 2>&1; then
    sudo apt install peco -y
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




echo "-------------------"
echo "手動で設定するもの"
echo "\t ターミナルのfontの設定"
echo "\t\t 1. font -> cousine for Powerfile Regular"
echo "\t\t 2. fontsize -> 14"
echo "\t VS code setting sync"
zsh