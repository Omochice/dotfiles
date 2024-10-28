{ ... }:
{
  xdg.configFile = {
    "glab-cli/aliases.yml".text = builtins.readFile ./aliases.yml;
  };
}
