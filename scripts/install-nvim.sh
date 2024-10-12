#!/bin/bash
# original is from Shougo/shougo-s-github/install-nvim

install_to="${HOME}/.local/nvim"

[ -d ${install_to} ] || mkdir -p ${install_to}

git clean -fdx

# patches {{{
cat <<EOF | git apply
diff --git a/runtime/lua/vim/_defaults.lua b/runtime/lua/vim/_defaults.lua
index 8e850f4cd3..c6e714b879 100644
--- a/runtime/lua/vim/_defaults.lua
+++ b/runtime/lua/vim/_defaults.lua
@@ -797,10 +797,4 @@ end
 
 --- Default options
 do
-  --- Default 'grepprg' to ripgrep if available.
-  if vim.fn.executable('rg') == 1 then
-    -- Use -uu to make ripgrep not check ignore files/skip dot-files
-    vim.o.grepprg = 'rg --vimgrep -uu '
-    vim.o.grepformat = '%f:%l:%c:%m'
-  end
 end
EOF
# }}}

make clean
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$install_to install

# Remove default plugins
if [ -d "${install_to}/share/nvim/runtime/plugin" ]; then
    [ -f "${install_to}/share/nvim/runtime/plugin/gzip.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/gzip.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/health.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/health.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/matchit.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/matchit.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/matchparen.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/matchparen.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/netrwPlugin.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/netrwPlugin.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/shada.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/shada.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/spellfile.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/spellfile.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/tarPlugin.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/tarPlugin.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/tohtml.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/tohtml.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/tutor.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/tutor.vim"
    [ -f "${install_to}/share/nvim/runtime/plugin/zipPlugin.vim" ] && rm "${install_to}/share/nvim/runtime/plugin/zipPlugin.vim"
fi
if [ -f "${install_to}/share/nvim/runtime/ftplugin.vim" ]; then
    rm "${install_to}/share/nvim/runtime/ftplugin.vim"
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
