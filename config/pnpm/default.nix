{ config, ... }:
{
  xdg.configFile."pnpm/config.yaml".source = ./config.yaml;
  home.sessionVariables.PNPM_HOME = "${config.xdg.dataHome}/pnpm";
  home.sessionPath = [ "${config.xdg.dataHome}/pnpm" ];
}
