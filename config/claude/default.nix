{ lib, pkgs, ... }:
let
  prefix = "claude-skill-";
  plugins =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix prefix)
    |> lib.attrsets.mapAttrs' (
      name: value: lib.attrsets.nameValuePair (lib.strings.removePrefix prefix name) value
    );
in
{
  xdg.configFile = {
    "claude/settings.json".text =
      {
        # TODO: use home-manager module instead
        includeCoAuthoredBy = false;
        statusLine = {
          type = "command";
          command = "${pkgs.ccusage}/bin/ccusage statusline";
          padding = 0;
        };
        sandbox = {
          enabled = true;
          autoAllowBashIfSandboxed = true;
        };
      }
      |> builtins.toJSON;
    "claude/CLAUDE.md".source = ./CLAUDE.md;
    "claude/commands".source = ./commands;
    "claude/skill/ast-grep".source = "${plugins.ast-grep.src}/ast-grep";
  };
}
