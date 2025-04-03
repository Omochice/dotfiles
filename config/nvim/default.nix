{ config, ... }:
{
  xdg.configFile = {
    "vim/vimrc" = {
      source = ./vimrc.core;
    };
    nvim.source =
      "${config.home.homeDirectory}/dotfiles/config/nvim" |> config.lib.file.mkOutOfStoreSymlink;
  };
}
