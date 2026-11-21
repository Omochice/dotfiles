{ pkgs, ... }:
{
  programs.my-git-wt = {
    enable = true;
    package = pkgs.nur.git-wt;
    enableFishIntegration = true;
    settings = {
      copy = [ ".pre-commit-config.yaml" ];
    };
  };
}
