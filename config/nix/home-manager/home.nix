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
in
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
    packages = with pkgs; [
      btop
      tldr
      pandoc
    ];
  };

  programs.home-manager.enable = true;
}
