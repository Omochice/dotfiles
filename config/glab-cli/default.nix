{ ... }:
{
  xdg.configFile = {
    "glab/aliases.yml".text = builtins.readFile ./aliases.yml;
  };
}
