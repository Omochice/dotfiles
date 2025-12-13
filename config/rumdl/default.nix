{ ... }:
{
  xdg.configFile = {
    "rumdl/rumdl.toml".text = builtins.readFile ./rumdl.toml;
  };
}
