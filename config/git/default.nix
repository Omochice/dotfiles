{ lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    includes = [
      { path = ./config; }
    ];
    aliases = {
      dd = ''
        !f() {
          ${pkgs.git}/bin/git branch -vv \
          | ${pkgs.gnugrep}/bin/grep ': gone]' \
          | ${pkgs.gawk}/bin/awk '{print $1}' \
          | ${pkgs.findutils}/bin/xargs -r ${pkgs.git}/bin/git branch -D
        };f
      '';
    };
    ignores = ./ignore |> builtins.readFile |> lib.splitString "\n";
    extraConfig = {
      commit.template = ./gitmessage |> toString;
    };
  };
}
