{
  pkgs,
  inputs,
  ...
}:
let
  org-babel = inputs.org-babel.lib;

  tangleOrg =
    options:
    pkgs.writeText "tangled" (org-babel.tangleOrgBabel options (builtins.readFile ./config.org));

  configEl = tangleOrg {
    languages = [ "emacs-lisp" ];
    tangleArg = "config.el";
  };

  packagesEl = tangleOrg {
    languages = [ "emacs-lisp" ];
    tangleArg = "packages.el";
  };

  doomDir = pkgs.runCommand "doom-dir" { } ''
    mkdir -p $out
    cp ${./init.el} $out/init.el
    cp ${configEl} $out/config.el
    cp ${packagesEl} $out/packages.el
  '';
in
{
  programs.doom-emacs = {
    enable = true;
    inherit doomDir;
  };
}
