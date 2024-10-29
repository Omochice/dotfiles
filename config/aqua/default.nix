{ config, ... }:
{
  xdg.configFile = {
    "aqua/dummy" = {
      text = builtins.readFile ./aqua.yaml;
      onChange = ''
        ln -snf ${config.home.homeDirectory}/dotfiles/config/aqua/aqua.yaml ${config.xdg.configHome}/aqua/aqua.yaml
      '';
    };
  };
}
