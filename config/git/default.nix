{ lib, ... }:
{
  programs.git = {
    enable = true;
    includes = [
      { path = ./config; }
    ];
    ignores = lib.splitString "\n" (builtins.readFile ./ignore);
    extraConfig = {
      commit.template = toString ./gitmessage;
    };
  };
}
