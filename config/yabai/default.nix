{ ... }:
{
  xdg.configFile = {
    "yabai/yabairc".text = builtins.readFile ./yabairc;
  };
}
