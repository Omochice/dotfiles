{ lib, pkgs, ... }:
let
  runAs =
    name: runtimeInputs: text:
    pkgs.writeShellApplication {
      inherit name runtimeInputs text;
    };
  git-dd =
    ''
      git branch -vv \
      | grep ': gone]' \
      | awk '{print $1}' \
      | xargs -r git branch -D
    ''
    |> runAs "git-dd" [
      pkgs.git
      pkgs.gnugrep
      pkgs.gawk
      pkgs.findutils
    ];
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull.override {
      svnSupport = true;
    };
    includes = [
      { path = ./config; }
    ];
    settings = {
      alias = {
        dd = "!${git-dd}/bin/git-dd";
      };
      commit.template = ./gitmessage |> toString;
    };
    ignores = ./ignore |> builtins.readFile |> lib.splitString "\n";
    lfs.enable = true;
  };
}
