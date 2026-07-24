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
      | awk '$1 != "+" && $1 != "*" {print $1}' \
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
    # keep-sorted start block=yes
    attributes = [ "* merge=mergiraf" ];
    enable = true;
    ignores = ./ignore |> builtins.readFile |> lib.splitString "\n";
    includes = [
      { path = ./config; }
    ];
    lfs.enable = true;
    package = pkgs.gitFull.override {
      svnSupport = true;
    };
    settings = {
      alias = {
        dd = "!${git-dd}/bin/git-dd";
      };
      mergiraf = {
        name = "mergiraf";
        driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
      };
      conflictStyle = "diff3";
      commit.template = "${./gitmessage}";
    };
    signing.format = null;
    # keep-sorted end
  };
}
