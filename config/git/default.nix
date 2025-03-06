{ lib, ... }:
{
  programs.git = {
    enable = true;
    includes = [
      { path = ./config; }
    ];
    ignores = ./ignore |> builtins.readFile |> lib.splitString "\n";
    extraConfig = {
      commit.template = ./gitmessage |> toString;
    };
  };
}
