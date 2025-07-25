{ ... }:
{
  xdg.configFile = {
    "claude/settings.json".source = ./settings.json;
    "claude/CLAUDE.md".source = ./CLAUDE.md;
    "claude/commands".source = ./commands;
  };
}
