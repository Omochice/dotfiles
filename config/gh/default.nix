{ ... }:
{
  xdg.configFile = {
    "gh/config.yml".text = builtins.readFile ./config.yml;
  };
}
