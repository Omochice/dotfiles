{ pkgs, ... }:
let
  init = pkgs.runCommand "zoxide-init.fish" { } ''
    ${pkgs.zoxide}/bin/zoxide init fish > $out
  '';
in
{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = false;
  };
  programs.fish.interactiveShellInit = "source ${init}";
}
