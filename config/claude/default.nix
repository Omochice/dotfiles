{
  config,
  lib,
  pkgs,
  ...
}:
let
  prefix = "claude-skill-";
  plugins =
    pkgs.dotfiles-sources
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix prefix)
    |> lib.attrsets.mapAttrs' (
      name: value: lib.attrsets.nameValuePair (lib.strings.removePrefix prefix name) value
    );
  statusLineScript = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./statusline.sh;
  };
  vocabCheck = pkgs.writeShellApplication {
    name = "chii-vocab-check";
    runtimeInputs = [ pkgs.gojq ];
    text = "exec gojq -c --yaml-input --rawfile hook /dev/stdin -f ${./output-styles/chii/vocab-check.jq} ${./output-styles/chii/prh.yaml}";
  };
  gitArg = "(?:\"[^\"]*\"|'[^']*'|\\S+)";
  # Global options such as `-C <path>` can sit between git and the subcommand, so matching `git\s+push` alone lets them through.
  gitCommand =
    sub:
    "\\bgit(?:\\s+(?:-[Cc]\\s+${gitArg}|--(?:git-dir|work-tree|namespace)\\s+${gitArg}|-(?!(?:[Cc]|-git-dir|-work-tree|-namespace)(?:\\s|$))\\S+))*\\s+${sub}";
  guardRules = (pkgs.formats.json { }).generate "guard-rules.json" [
    {
      matcher = "Bash";
      regex = gitCommand "push(?![\\w-])";
      message = "Use of 'git push' is prohibited. Ask the user to execute it.";
    }
    {
      matcher = "Bash";
      regex = "\\bgh\\s+stack\\s+(submit|push|merge|unstack|link)\\b";
      message = "Use of 'gh stack submit/push/merge/unstack/link' is prohibited because it writes to the remote. Ask the user to execute it.";
    }
    {
      matcher = "Bash";
      regex = gitCommand "add\\s+(-A|--all|\\.($|[ ;|&]))";
      message = "Do not git-add all files. Specify the files to add.";
    }
    {
      matcher = "Bash";
      regex = gitCommand "rebase\\s+.*--autosquash";
      message = "Do not --autosquash for rebase fixup commits. Ask the user to execute it.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)git-surgeon\\s+(?:amend|fold)\\b";
      message = "Use of 'git-surgeon amend/fold' is prohibited because it rewrites an existing commit. Use 'git commit --fixup' instead.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)git-surgeon\\s+discard\\b";
      message = "Use of 'git-surgeon discard' is prohibited because it destroys working tree changes irreversibly. Ask the user to execute it.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)git-surgeon\\s+update\\b";
      message = "Use of 'git-surgeon update' is prohibited because git-surgeon is managed by nix.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)sed\\s+-n\\s+(?!(['\"]?)\\d+(?:,\\d+)?p\\1(?:[\\s;|&)]|$))";
      message = "Only 'sed -n N,Mp' and 'sed -n Np' are allowed. Use the Read tool with offset and limit instead.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)awk\\s+'?\\s*NR\\s*[<>=]";
      message = "Use of 'awk' is prohibited. Use the Read tool with offset and limit instead.";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)sed\\b(?!\\s+-n\\s)";
      message = "Use of 'sed' is prohibited. Use 'perl' instead. Example: perl -pi -e 's/old/new/g' file.txt";
    }
    {
      matcher = "Bash";
      regex = "(?:^|[|;&(]\\s*)awk\\b";
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
    {
      matcher = "Bash";
      regex = "glab\\s+(variable|var)\\b";
      message = "Do not read repository variables, If you want to check the variable exists, ask user to check it.";
    }
    {
      matcher = "Read|Write|Edit";
      regex = ".config/glab-cli/config\\.yml$";
      message = "Do not read glab config file. If failed to access gitlab, ask user to resolve it.";
    }
    {
      matcher = "Read|Write|Edit";
      regex = "\\.envrc$";
      message = "Do not read credential config file. If failed to access some endpoints, ask user to resolve it.";
    }
    {
      matcher = "Read|Write|Edit";
      regex = "\\.ssh";
      message = "Do not read credential config file. If failed to access some endpoints, ask user to resolve it.";
    }
  ];
  guardHook = pkgs.writeShellApplication {
    name = "claude-guard";
    runtimeInputs = [ pkgs.jq ];
    # gojq cannot be used because its regexp has no lookaround.
    # jq exits non-zero on a broken rule, and only exit code 2 blocks the tool call, so a broken rule fails closed.
    text = "jq -c --slurpfile rules ${guardRules} -f ${./guard.jq} || exit 2";
  };
  localOmm = pkgs.writeShellApplication {
    name = "omm";
    # Prevent non-local commands.
    text = ''
      case "''${1:-}" in
        login | logout | link | push | pull | share | org)
          echo "omm: '$1' is disabled because omm is used only locally" >&2
          exit 1
          ;;
        setup | update)
          echo "omm: '$1' is disabled because omm and its skills are managed by nix" >&2
          exit 1
          ;;
      esac
      exec ${lib.getExe pkgs.oh-my-mermaid} "$@"
    '';
  };

  stripAcknowledgement =
    content:
    let
      m = builtins.match "([[:space:][:graph:]]*)<!--[[:space:][:graph:]]*-->[[:space:]]*$" content;
    in
    if m == null then content else builtins.head m;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.llm-pkgs.claude-code;
    configDir = "${config.xdg.configHome}/claude";
    context = ./CLAUDE.md;
    settings = {
      # keep-sorted start block=yes
      advisorModel = "fable";
      attribution.commit = "";
      attribution.pr = "";
      attribution.sessionUrl = false;
      effortLevel = "medium";
      enableAllProjectMcpServers = true;
      env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
      env.CLAUDE_CODE_SUBAGENT_MODEL = "opus[1m]";
      # Unlike DISABLE_TELEMETRY, this stops only the plugin's usage counts and leaves Claude Code's own telemetry as it is.
      env.CODE_MODERNIZATION_TELEMETRY = "0";
      env.IS_DEMO = "true";
      hooks.PreToolUse = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = lib.getExe guardHook;
            }
          ];
        }
      ];
      hooks.Stop = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = lib.getExe vocabCheck;
              timeout = 10;
            }
          ];
        }
      ];
      model = "opus[1m]";
      outputStyle = "chii";
      permissions.defaultMode = "auto";
      permissions.deny = [
        "Read(~/.ssh/**)"
        "Edit(~/.ssh/**)"
      ];
      plansDirectory = "./.momomo/ai/plans";
      remoteControlAtStartup = true;
      sandbox.autoAllowBashIfSandboxed = true;
      sandbox.enabled = true;
      sandbox.excludedCommands = [
        # .git/config is a protected path that allowWrite cannot open, so commands that rewrite it must leave the sandbox
        "git branch *"
        "git submodule *"
        "git switch *"
        "git worktree *"
        "git-wt *"
      ];
      sandbox.filesystem.allowWrite = [
        "~/.cache/prek"
        "~/.local/share/mergiraf"
      ];
      sandbox.network.allowUnixSockets = [ "/nix/var/nix/daemon-socket/socket" ];
      sandbox.network.allowedDomains = [
        "api.github.com"
        "github.com"
      ];
      showClearContextOnPlanAccept = true;
      statusLine.command = lib.getExe statusLineScript;
      statusLine.padding = 0;
      statusLine.type = "command";
      teammateMode = "auto";
      worktree.baseRef = "head";
      # keep-sorted end
    };
    commands = {
      # keep-sorted start
      kiro = builtins.readFile ./commands/kiro.md;
      # keep-sorted end
    };
    plugins = {
      # keep-sorted start
      code-modernization = "${plugins.claude-plugins-official.src}/plugins/code-modernization";
      # keep-sorted end
    };
    outputStyles = {
      # keep-sorted start
      chii = builtins.readFile ./output-styles/chii/style.md;
      # keep-sorted end
    };
    rules = {
      # keep-sorted start
      ai-agent-working-directory = builtins.readFile ./rules/temporary-directory.md;
      commit = builtins.readFile ./rules/commit.md;
      conversation = builtins.readFile ./rules/conversation.md;
      documentation = builtins.readFile ./rules/documentation.md;
      shell-command = builtins.readFile ./rules/shell-command.md;
      simple-not-easy = builtins.readFile ./rules/simple-not-easy.md;
      sub-agent = builtins.readFile ./rules/sub-agent.md;
      tidy-first = builtins.readFile ./rules/tidy-first.md;
      worktree = builtins.readFile ./rules/worktree.md;
      # keep-sorted end
    };
    skills = {
      # keep-sorted start
      adr = builtins.readFile ./skills/adr.md;
      adr-update = builtins.readFile ./skills/adr-update.md;
      ast-grep = "${plugins.ast-grep.src}/ast-grep/skills/ast-grep/";
      commit = "${plugins.tani.src}/commit/";
      copilot-review = builtins.readFile ./skills/copilot-review.md;
      create-pr = builtins.readFile ./skills/create-pr.md;
      gh-stack = "${pkgs.gh-stack.src}/skills/gh-stack/";
      git-surgeon = "${pkgs.git-surgeon.src}/skills/git-surgeon/";
      grill-me = "${plugins.mattpocock.src}/skills/productivity/grill-me/";
      grilling = builtins.readFile ./skills/grilling.md |> stripAcknowledgement;
      handoff = "${plugins.mattpocock.src}/skills/productivity/handoff/";
      omm-scan = "${pkgs.oh-my-mermaid.src}/skills/omm-scan/";
      omm-view = "${pkgs.oh-my-mermaid.src}/skills/omm-view/";
      retrospective = "${plugins.lacolaco.src}/retrospective/";
      review-pr = builtins.readFile ./skills/review-pr.md;
      skill-creator = "${plugins.anthropics.src}/skills/skill-creator/";
      specified-test = builtins.readFile ./skills/specified-test.md;
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
      playwright = {
        type = "stdio";
        command = lib.getExe pkgs.playwright-mcp;
      };
      # keep-sorted end
    };
  };
  home.packages = [
    pkgs.git-surgeon
    localOmm
  ];
}
