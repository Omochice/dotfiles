{ ... }:
{
  xdg.configFile = {
    "vim/vimrc" = {
      source = ./vimrc.core;
    };
    # "nvim" = {
    #   source = ./.;
    #   recursive = true;
    # };
  };
}
