{
  inputs,
  lib,
  config,
  pkgs,
  nur-packages,
  ...
}:
let
  # FIXME: I dont want to write user name here, but it doesn't work without "--impure"
  username = builtins.getEnv "USER";
  homeDirectory = builtins.getEnv "HOME";
  nur = nur-packages.packages.${pkgs.system};
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
      # keep-sorted start
      btop
      cachix
      cargo
      clang-tools
      curl
      devbox
      fish
      gnumake
      imagemagick
      mise
      neofetch
      nix-output-monitor
      nixd
      nkf
      nushell
      pandoc
      pnpm
      silicon
      starship
      tldr
      # keep-sorted end
      # keep-sorted start
      nur.firge
      nur.firge-nerd
      nur.pinact
      # keep-sorted end
    ];
  };
  programs.home-manager.enable = true;
  xdg.enable = true;
}
