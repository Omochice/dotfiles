{ ... }:
{
  # settings.toml is left out because Adroit rewrites it whenever a setting changes.
  xdg.configFile = {
    "adroit/keys.toml".source = ./keys.toml;
    "adroit/themes/yuzu".source = ./themes/yuzu;
    "adroit/prompt/nvim/init.lua".source = ./prompt/nvim/init.lua;
  };
}
