{
  neovim-src,
  pkgs,
}:
let
  deps = pkgs.callPackage ./deps.nix { inherit neovim-src; };
  moldStdenv = pkgs.useMoldLinker pkgs.clangStdenv;
in
moldStdenv.mkDerivation {
  name = "neovim";
  src = neovim-src;
  buildInputs = with pkgs; [
    cmake
    gettext
  ];
  patches = [
    ./patches/delete-rg-executable.patch
  ];
  postPatch = ''
    cp -a ${deps} .deps
    chmod -R +w .deps
  '';
  postInstall = ''
    # Remove default plugins
    rm -f $out/share/nvim/runtime/plugin/gzip.vim
    rm -f $out/share/nvim/runtime/plugin/health.vim
    rm -f $out/share/nvim/runtime/plugin/matchit.vim
    rm -f $out/share/nvim/runtime/plugin/matchparen.vim
    rm -f $out/share/nvim/runtime/plugin/netrwPlugin.vim
    rm -f $out/share/nvim/runtime/plugin/shada.lua
    rm -f $out/share/nvim/runtime/plugin/spellfile.vim
    rm -f $out/share/nvim/runtime/plugin/tarPlugin.vim
    rm -f $out/share/nvim/runtime/plugin/tohtml.lua
    rm -f $out/share/nvim/runtime/plugin/tutor.vim
    rm -f $out/share/nvim/runtime/plugin/zipPlugin.vim

    # Remove ftplugin.vim if exists
    rm -f $out/share/nvim/runtime/ftplugin.vim

    # Create vim alias symlink
    ln -s $out/bin/nvim $out/bin/vim
  '';
  # installPhaseでもビルド走るのでbuildPhaseを潰す
  buildPhase = "true";
}
