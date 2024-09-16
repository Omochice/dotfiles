{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  # FIXME: I dont want to write user name here, but it doesn't work without "--impure"
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  home = {
    username = username;
    homeDirectory = homeDirectory;
    stateVersion = "24.05";
    packages = with pkgs; [
      btop
      tldr
      pandoc
      cargo
      starship
      curl
      nushell
      fish
      gnumake
      mise
      pnpm
    ];
  };

  programs.home-manager.enable = true;
}