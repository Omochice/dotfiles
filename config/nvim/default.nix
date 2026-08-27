{ config, ... }:
{
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
