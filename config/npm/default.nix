{ ... }:
{
  home.file.".npmrc".text = builtins.readFile ./npmrc;
}
