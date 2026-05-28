{ config, ... }:
{
  xdg.configFile."npm/npmrc".text = builtins.readFile ./npmrc;
  home.sessionVariables = {
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
  };
}
