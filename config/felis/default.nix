{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.felis.homeManagerModules.felis ];

  programs.felis = {
    enable = true;
    package = inputs.felis.packages.${pkgs.stdenv.hostPlatform.system}.felis;
    settings = {
      font = {
        family = "Firge35Nerd Console";
        size_px = 20;
      };
      window.opacity = 0.8;
      cursor = {
        color = "#EDE7F7";
        blink = "never";
      };
      theme = {
        # yuzu theme
        background = "#000000";
        foreground = "#EDE7F7";
        palette = {
          black = "#1E1B2B";
          red = "#D95C73";
          green = "#9FD6B7";
          yellow = "#F4D66A";
          blue = "#5E9BEB";
          magenta = "#C27AE8";
          cyan = "#77D6E6";
          white = "#EDE7F7";
          bright_black = "#726A94";
          bright_red = "#D95C73";
          bright_green = "#9FD6B7";
          bright_yellow = "#F4D66A";
          bright_blue = "#5E9BEB";
          bright_magenta = "#C27AE8";
          bright_cyan = "#77D6E6";
          bright_white = "#FFFDFE";
        };
      };
    };
  };
}
