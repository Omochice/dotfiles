{ config, ... }:
{
  xdg.configFile = {
    "mise/config.toml".text = builtins.readFile ./config.toml;
  };
  # Shell activation is intentionally off: it runs `mise hook-env` on every
  # prompt. Per-project environments come from direnv's `use mise`, and the
  # global tools are reached through the shims directory on PATH.
  programs.mise = {
    enable = true;
    enableNushellIntegration = false;
    enableFishIntegration = false;
  };
  home.sessionPath = [ "${config.xdg.dataHome}/mise/shims" ];
}
