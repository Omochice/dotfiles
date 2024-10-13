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
    shellAliases = builtins.listToAttrs (
      builtins.map
        (item: {
          name = item.to;
          value = item.from;
        })
        (
          builtins.filter (item: (isMatchOs item) && (isTargetNushell item))
            (builtins.fromTOML (builtins.readFile ../../path-list.toml)).aliases
        )
    );
  };
}
