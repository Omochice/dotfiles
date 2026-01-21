{ pkgs, ... }:
let
  osName = if pkgs.stdenv.isDarwin then "darwin" else "linux";
  isTargetNushell = item: if builtins.hasAttr "shell" item then item.shell == "nu" else true;
  isMatchOs = item: if builtins.hasAttr "os" item then item.os == osName else true;
in
{
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    shellAliases =
      ../../path-list.toml
      |> builtins.readFile
      |> fromTOML
      |> builtins.getAttr "aliases"
      |> builtins.filter (item: (isMatchOs item) && (isTargetNushell item))
      |> map (item: {
        name = item.to;
        value = item.from;
      })
      |> builtins.listToAttrs;
  };
}
