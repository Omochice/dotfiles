{ pkgs, ... }:
{
  programs.my-git-wt = {
    enable = true;
    package = pkgs.git-wt;
    enableFishIntegration = true;
  };
}
