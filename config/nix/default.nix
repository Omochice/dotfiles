{ config, ... }:
{
  xdg.configFile = {
    "nix/nix.conf".text = builtins.readFile ./nix.conf;
  };
  home.sessionPath = [ "${config.home.homeDirectory}/.nix-profile/bin" ];
}
