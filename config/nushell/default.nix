{ ... }:
let
  osName = if builtins.match ".*darwin" builtins.currentSystem == null then "linux" else "darwin";
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
      |> builtins.fromTOML
      |> builtins.getAttr "aliases"
      |> builtins.filter (item: (isMatchOs item) && (isTargetNushell item))
      |> builtins.map (item: {
        name = item.to;
        value = item.from;
      })
      |> builtins.listToAttrs;
  };
}
