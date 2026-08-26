{ lib, pkgs, ... }:
let
  # nixpkgs removes share/fish in postInstall, but its custom installPhase
  # never runs that hook, so the vendor conf that hooks direnv survives.
  direnv = pkgs.direnv.overrideAttrs (prev: {
    installPhase = prev.installPhase + ''
      rm -rf $out/share/fish
    '';
  });
  hook = pkgs.runCommand "direnv-hook.fish" { } ''
    ${direnv}/bin/direnv hook fish > $out
  '';
in
{
  programs.direnv = {
    enable = true;
    package = direnv;
    nix-direnv.enable = true;
    mise.enable = true;
    enableFishIntegration = false;
  };
  programs.fish.interactiveShellInit = lib.mkAfter ''
    if not functions -q __direnv_export_eval
      source ${hook}
    end
  '';
}
