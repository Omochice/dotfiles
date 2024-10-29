{ ... }:
{
  xdg.configFile = {
    "wezterm" = {
      source = ./.;
      recursive = true;
    };
  };
}
