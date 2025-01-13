{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  loadFlake = flakePath: (builtins.getFlake (toString flakePath)).packages.${pkgs.system}.default;
  # FIXME: I dont want to write user name here, but it doesn't work without "--impure"
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
  firgeFont = loadFlake ../../font/firge;
  firgeNerdFont = loadFlake ../../font/firge-nerd;
in
{
  imports = [
    ../../git/default.nix
    ../../starship/default.nix
    ../../lazygit/default.nix
    ../../nushell/default.nix
    ../../zoxide/default.nix
    ../../glab-cli/default.nix
    ../../gh/default.nix
    ../../aqua/default.nix
    ../../yabai/default.nix
    ../../wezterm/default.nix
    ../../nvim/default.nix
    ../../colima/default.nix
    # ../../macskk/default.nix
  ];
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
      cargo
      clang-tools
      curl
      devbox
      fish
      gnumake
      imagemagick
      mise
      neofetch
      nixd
      nkf
      nushell
      pandoc
      pnpm
      starship
      tldr
      nix-output-monitor
      firgeFont
      firgeNerdFont
    ];
  };
  programs.home-manager.enable = true;
  xdg.enable = true;
}
