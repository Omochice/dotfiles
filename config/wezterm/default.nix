{ lib, ... }:
{
  xdg.configFile = {
    "wezterm" = {
      source = ./.;
      recursive = true;
    };
  };
  programs = {
    fish.interactiveShellInit = lib.mkAfter ''
      set --export --unpath TERMINAL wezterm
    '';
  };
}
