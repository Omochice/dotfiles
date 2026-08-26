{ pkgs, ... }:
let
  activate = pkgs.runCommand "mise-activate.fish" { } ''
    ${pkgs.mise}/bin/mise activate fish > $out
  '';
in
{
  xdg.configFile = {
    "mise/config.toml".text = builtins.readFile ./config.toml;
  };
  programs.mise = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = false;
  };
  programs.fish.interactiveShellInit = "source ${activate}";
}
