{
  pkgs,
  sources,
}:
let
  neovim-unwrapped-omochice = pkgs.neovim-unwrapped.overrideAttrs (old: {
    pname = "neovim-unwrapped-omochice";
    version = sources.neovim.version;

    src = sources.neovim.src;

    # Skip version check since nvfetcher uses commit hash as version
    doInstallCheck = false;

    patches = (old.patches or [ ]) ++ [
      ./patches/delete-rg-executable.patch
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
neovim-unwrapped-omochice
