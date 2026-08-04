{ config, ... }:
{
  xdg.configFile = {
    "vim/vimrc" = {
      source = ./vimrc.core;
    };
    nvim.source = "${config.my.dotfilesDir}/config/nvim" |> config.lib.file.mkOutOfStoreSymlink;
  };
}
