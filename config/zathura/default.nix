{ pkgs, ... }:
let
  plugins = pkgs.callPackage ../../_sources/generated.nix { };
in
{
  programs.zathura = {
    enable = true;
    extraConfig = ''
      include ${plugins.zathura-catputtin.src}/themes/catppuccin-latte
    '';
    mappings = {
      d = "scroll half-down";
      u = "scroll half-up";
      "|" = "toggle_page_mode";
    };
  };
}
