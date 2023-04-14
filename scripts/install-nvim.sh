#!/bin/sh
# original is from Shougo/shougo-s-github/install-nvim

make clean
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=~/.local/nvim install

# Remove default plugins
if [ -d ~/.local/nvim/share/nvim/runtime/plugin ]; then
    rm ~/.local/nvim/share/nvim/runtime/plugin/gzip.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/health.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/matchit.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/matchparen.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/netrwPlugin.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/shada.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/spellfile.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/tarPlugin.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/tohtml.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/tutor.vim
    rm ~/.local/nvim/share/nvim/runtime/plugin/zipPlugin.vim
fi
if [ -f ~/.local/nvim/share/nvim/runtime/ftplugin.vim ]; then
    rm ~/.local/nvim/share/nvim/runtime/ftplugin.vim
fi
if [ -d /usr/share/vim/vimfiles/plugin ]; then
    rm -Rf /usr/share/vim/vimfiles/plugin
fi
if [ -f /etc/xdg/nvim/sysinit.vim ]; then
    rm /etc/xdg/nvim/sysinit.vim
fi
if [ -f /usr/share/nvim/archlinux.vim ]; then
    rm /usr/share/nvim/archlinux.vim
fi
