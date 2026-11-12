{ config, pkgs, ... }:
{
  # skkeleton reads it from stdpath("data"), which the out-of-store Lua config can name without Nix.
  xdg.dataFile."nvim/skk/SKK-JISYO.L".source = pkgs.skk-jisyo-l-utf8;
  xdg.configFile = {
    "vim/vimrc" = {
      source = ./vimrc.core;
    };
    nvim.source = "${config.my.dotfilesDir}/config/nvim" |> config.lib.file.mkOutOfStoreSymlink;
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };
  home.shellAliases = {
    ":q" = "exit";
    vim = "nvim";
    view = "nvim -R";
  };
}
