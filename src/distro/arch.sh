#!/bin/bash -eu

sudo pacman-mirrors --fasttrack

sudo pacman -Syyu

sudo pacman -S fcitx-im fcitx-mozc

sudo pacman -S xdg-user-dirs-gtk

sudo pacman -S yay

sudo pacman -S vim

printf "zsh... "
if ! type "zsh" >/dev/null 2>&1; then
    printf " installing... "
    sudo pacman -S zsh
    printf "done.\n"
else
    printf " already installed.\n"
fi
for rcfile in $(ls -d $HOME/dotfiles/zshell/z*); do
    rm -rf "${ZDOTDIR:-$HOME}/.$(basename $rcfile)"
    ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.$(basename $rcfile)"
done


printf "bat... "
if ! [ -x "$(command -v bat)" ] && ! [ -x "$(command -v batcat)" ]; then
    printf "installing... "
    sudo pacman -S bat
    echo "done."
else
    echo "already installed."
fi

printf "curl ... "
if ! [ -x "$(command -v curl)" ]; then
    printf "installing... "
    sudo pacman -S curl
    echo "done."
else
    echo "already installed."
fi

printf "exa... "
if ! [ -x "$(command -v exa)" ]; then
    printf "installing... "
    sudo yay -S exa
    echo "done."
else
    echo "already installed."
fi

printf "xsel... "
if ! [ -x "$(command -v xsel)" ]; then
    printf "installing... "
    sudo yay -S xsel
    echo "done."
else
    echo "already installed."
fi

# printf "ripgrep... "
# if ! [ -x "$(command -v ripgrep)" ]; then
#     printf "installing... "
#     curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep_12.0.1_amd64.deb ~/
#     sudo apt install -y ~/ripgrep_12.0.1_amd64.deb > /dev/null
#     rm ~/ripgrep_12.0.1_amd64.deb
#     echo "done."
# else
#     echo "already installed."
# fi

printf "peco... "
if ! [ -x "$(command -v peco)" ]; then
    printf "installing... "
    yay install peco
    echo "done."
else
    echo "already installed."
fi

printf "tmux... "
if ! [ -x "$(command -v tmux)" ]; then
    printf "installing... "
    sudo pacman -S tmux
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

# printf "git(latest)... "
# if ! [ -x "$(command -v git)" ]; then
#     printf "installing... "
#     sudo add-apt-repository ppa:git-core/ppa
#     sudo apt update > /dev/null
#     sudo apt install git > /dev/null
#     echo "done."
# else
#     echo "already installed."
# fi

printf "VScode... "
if ! [ -x "$(command -v code)" ]; then
    printf "installing... "
    yay -S visual-studio-code-bin
    echo "done."
else
    echo "already installed."
fi

printf "vivaldi... "
if ! [ -x "$(command -v vivaldi)" ]; then
    printf "installing... "
    yay -S vivaldi
    echo "done."
else
    echo "already installed."
fi

printf "Fish shell"
if ! type "fish" >/dev/null 2>&1; then
    sudo pacman -S fish
    curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
    fisher add jethrokuan/z oh-my-fish/plugin-extract oh-my-fish/plugin-peco rstacruz/fish-autols
fi

# Toggle IME
sed -i "s/TriggerKey=.*/TriggerKey=HENKAN ZENKAKUHANKAKU/" $HOME/.config/fcitx/config

# 手動設定
# Mozcのキーボードレイアウト
# セッションと起動 -> 起動時にgnomeを有効化(キーリングの無効化)
