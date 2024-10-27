{ ... }:
{
  xdg.configFile = {
    "aqua/aqua.yaml".text = builtins.readFile ./aqua.yaml;
  };
}
