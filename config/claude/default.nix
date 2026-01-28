{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  prefix = "claude-skill-";
  plugins =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix prefix)
    |> lib.attrsets.mapAttrs' (
      name: value: lib.attrsets.nameValuePair (lib.strings.removePrefix prefix name) value
    );
  anthropic-skills =
    pkgs.callPackage ../../_sources/generated.nix { } |> builtins.getAttr "anthropics-skills";
  tani-skills = pkgs.callPackage ../../_sources/generated.nix { } |> builtins.getAttr "tani-skills";
in
{
  programs.my-claude-code = {
    enable = true;
    package = llm-pkgs.claude-code;
    memory.source = ./CLAUDE.md;
    settings = {
      includeCoAuthoredBy = false;
      statusLine = {
        type = "command";
        command = "${llm-pkgs.ccusage}/bin/ccusage statusline";
        padding = 0;
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
      };
      model = "opusplan";
    };
    commands = {
      # keep-sorted start
      kiro = builtins.readFile ./commands/kiro.md;
      mr-comments = builtins.readFile ./commands/mr-comments.md;
      # keep-sorted end
    };
    skills = {
      # keep-sorted start
      ast-grep = "${plugins.ast-grep.src}/ast-grep/skills/ast-grep/";
      commit = "${tani-skills.src}/commit/";
      review-pr = builtins.readFile ./skills/review-pr.md;
      skill-creator = "${anthropic-skills.src}/skills/skill-creator/";
      # keep-sorted end
    };
    mcpServers = {
      # keep-sorted start block=yes
      context7 = {
        type = "stdio";
        command = "${pkgs.context7-mcp}/bin/context7-mcp";
      };
      deepwiki-mcp = {
        type = "http";
        url = "https://mcp.deepwiki.com/mcp";
      };
      git-mcp = {
        type = "stdio";
        command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
      };
      playwright = {
        type = "stdio";
        command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      };
      # keep-sorted end
    };
  };
}
