{ config, ... }:
{
  xdg.configFile = {
    "aqua/dummy" = {
      text = ./aqua.yaml |> builtins.readFile;
      onChange = ''
        ln -snf ${config.home.homeDirectory}/dotfiles/config/aqua/aqua.yaml ${config.xdg.configHome}/aqua/aqua.yaml
      '';
    };
  };
}
