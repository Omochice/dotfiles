{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  guard-and-guide = inputs.guard-and-guide.packages.${pkgs.stdenv.hostPlatform.system} // {
    default = inputs.guard-and-guide.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs {
      doCheck = false;
    };
  };
  prefix = "claude-skill-";
  plugins =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix prefix)
    |> lib.attrsets.mapAttrs' (
      name: value: lib.attrsets.nameValuePair (lib.strings.removePrefix prefix name) value
    );
  tomlFormat = pkgs.formats.toml { };
in
{
  programs.my-claude-code = {
    enable = true;
    package = llm-pkgs.claude-code;
    memory.source = ./CLAUDE.md;
    settings = {
      # keep-sorted start block=yes
      env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      env.IS_DEMO = "true";
      hooks.PreToolUse = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "${lib.getExe guard-and-guide.default}";
            }
          ];
        }
      ];
      includeCoAuthoredBy = false;
      model = "opus";
      permissions.defaultMode = "bypassPermissions";
      plansDirectory = "./.momomo/ai/plans";
      remoteControlAtStartup = true;
      sandbox.autoAllowBashIfSandboxed = true;
      sandbox.enabled = true;
      showClearContextOnPlanAccept = true;
      statusLine.command = "${lib.getExe llm-pkgs.ccusage} statusline";
      statusLine.padding = 0;
      statusLine.type = "command";
      teammateMode = "auto";
      # keep-sorted end
    };
    commands = {
      # keep-sorted start
      kiro = builtins.readFile ./commands/kiro.md;
      mr-comments = builtins.readFile ./commands/mr-comments.md;
      # keep-sorted end
    };
    rules = {
      # keep-sorted start
      ai-agent-working-directory = builtins.readFile ./rules/temporary-directory.md;
      commit = builtins.readFile ./rules/commit.md;
      conversation = builtins.readFile ./rules/conversation.md;
      documentation = builtins.readFile ./rules/documentation.md;
      simple-not-easy = builtins.readFile ./rules/simple-not-easy.md;
      tidy-first = builtins.readFile ./rules/tidy-first.md;
      # keep-sorted end
    };
    skills = {
      # keep-sorted start
      ast-grep = "${plugins.ast-grep.src}/ast-grep/skills/ast-grep/";
      commit = "${plugins.tani.src}/commit/";
      create-pr = builtins.readFile ./skills/create-pr.md;
      review-pr = builtins.readFile ./skills/review-pr.md;
      skill-creator = "${plugins.anthropics.src}/skills/skill-creator/";
      tdd = builtins.readFile ./skills/tdd.md;
      # keep-sorted end
    };
    mcpServers = {
      # keep-sorted start block=yes
      context7 = {
        type = "stdio";
        command = lib.getExe pkgs.context7-mcp;
      };
      deepwiki-mcp = {
        type = "http";
        url = "https://mcp.deepwiki.com/mcp";
      };
      git-mcp = {
        type = "stdio";
        command = lib.getExe pkgs.mcp-server-git;
      };
      playwright = {
        type = "stdio";
        command = lib.getExe pkgs.playwright-mcp;
      };
      # keep-sorted end
    };
  };
  xdg.configFile."guard-and-guide/rules.toml".source = builtins.toPath (
    tomlFormat.generate "rules.toml" {
      version = 1;
      rules = [
        {
          matcher = "Bash";
          regex = "\\bgit\\s+push\\b";
          message = "Use of 'git push' is prohibited. Ask the user to execute it.";
        }
        {
          matcher = "Bash";
          regex = "\\bgit\\s+add\\s+(-A|--all|\\.($|[ ;|&]))";
          message = "Do not git-add all files. Specify the files to add.";
        }
        {
          matcher = "Bash";
          regex = "\\bgit\\s+rebase\\s+.*--autosquash";
          message = "Do not --autosquash for rebase fixup commits. Ask the user to execute it.";
        }
        {
          matcher = "Bash";
          regex = "\\bsed\\b";
          message = "Use of 'sed' is prohibited. Use 'perl' instead. Example: perl -pi -e 's/old/new/g' file.txt";
        }
        {
          matcher = "Bash";
          regex = "\\bawk\\b";
          message = "Use of 'awk' is prohibited. Use 'perl' instead. Example: perl -lane 'print $F[0]' file.txt";
        }
        {
          matcher = "Write|Edit";
          regex = "(pnpm-lock\\.yaml|package-lock\\.json|deno\\.lock|bun\\.lockb?)$";
          message = "Lock files are read-only. Do not modify them directly.";
        }
        {
          matcher = "Bash";
          regex = "^(pip|pip3)\\b";
          message = "Do not use `pip`, Use uv for installing package isolatly";
        }
      ];
    }
  );
}
