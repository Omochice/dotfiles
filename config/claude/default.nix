{ pkgs, ... }:
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
  };
}
