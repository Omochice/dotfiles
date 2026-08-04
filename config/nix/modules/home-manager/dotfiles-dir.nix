{ config, lib, ... }:
{
  options.my.dotfilesDir = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dotfiles";
    description = "Absolute path to the dotfiles checkout";
  };
}
