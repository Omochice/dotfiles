{ ... }:
{
  xdg.configFile = {
    "nix/nix.conf".text = builtins.readFile ./nix.conf;
  };
}
