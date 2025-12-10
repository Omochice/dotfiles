{ ... }:
{
  xdg.configFile = {
    "mise/config.toml".text = builtins.readFile ./config.toml;
  };
  programs.mise = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };
}
