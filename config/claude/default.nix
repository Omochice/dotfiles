{ pkgs, ... }:
{
  xdg.configFile = {
    "claude/settings.json".text =
      ./settings.json
      |> builtins.readFile
      |> builtins.fromJSON
      |> pkgs.lib.attrsets.filterAttrs (k: _: k != "$schema")
      |> builtins.toJSON;
    "claude/CLAUDE.md".source = ./CLAUDE.md;
    "claude/commands".source = ./commands;
  };
}
