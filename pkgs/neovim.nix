{
  pkgs,
  sources,
}:
let
  neovim-unwrapped-custom = pkgs.neovim-unwrapped.overrideAttrs (old: {
    pname = "neovim-unwrapped-custom";
    version = sources.neovim.version;

    src = sources.neovim.src;

    # Skip version check since nvfetcher uses commit hash as version
    doInstallCheck = false;

    patches = (old.patches or [ ]) ++ [
      # Disable default ripgrep integration in grepprg
      (pkgs.writeText "disable-rg-grepprg.patch" ''
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
      '')
    ];

    postInstall = (old.postInstall or "") + ''
      # Remove default plugins
      rm -f $out/share/nvim/runtime/plugin/gzip.vim
      rm -f $out/share/nvim/runtime/plugin/health.vim
      rm -f $out/share/nvim/runtime/plugin/matchit.vim
      rm -f $out/share/nvim/runtime/plugin/matchparen.vim
      rm -f $out/share/nvim/runtime/plugin/netrwPlugin.vim
      rm -f $out/share/nvim/runtime/plugin/shada.vim
      rm -f $out/share/nvim/runtime/plugin/spellfile.vim
      rm -f $out/share/nvim/runtime/plugin/tarPlugin.vim
      rm -f $out/share/nvim/runtime/plugin/tohtml.vim
      rm -f $out/share/nvim/runtime/plugin/tutor.vim
      rm -f $out/share/nvim/runtime/plugin/zipPlugin.vim

      # Remove ftplugin.vim if exists
      rm -f $out/share/nvim/runtime/ftplugin.vim

      # Create vim alias symlink
      ln -s $out/bin/nvim $out/bin/vim
    '';
  });
in
neovim-unwrapped-custom
