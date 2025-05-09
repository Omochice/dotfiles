{ pkgs, ... }:
let
  plugins = pkgs.callPackage ../../_sources/generated.nix { };
in
{
  xdg.configFile = {
    "yazi/theme.toml".source =
      "${plugins.yazi-theme-catppuccin.src}/themes/mocha/catppuccin-mocha-maroon.toml";
    "yazi/Catppuccin-mocha.tmTheme".source =
      "${plugins.bat-theme-catppuccin.src}/themes/Catppuccin Mocha.tmTheme";
  };
}
