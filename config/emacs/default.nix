{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  org-babel = inputs.org-babel.lib;

  tangle =
    tangleArg:
    pkgs.writeText tangleArg (
      org-babel.tangleOrgBabel {
        languages = [ "emacs-lisp" ];
        inherit tangleArg;
      } (builtins.readFile ./config.org)
    );

  packages =
    epkgs: with epkgs; [
      # keep-sorted start
      browse-at-remote
      clipetty
      consult
      corfu
      corfu-terminal
      ddskk
      diff-hl
      evil
      evil-collection
      evil-indent-plus
      evil-nerd-commenter
      evil-surround
      evil-terminal-cursor-changer
      evil-visualstar
      kkp
      magit
      marginalia
      markdown-mode
      orderless
      vertico
      xclip
      # keep-sorted end
    ];

  # emacsPackagesFor would byte-compile every package with neomacs, which fails on ddskk.
  neomacs =
    let
      siteLisp = "${config.programs.emacs.finalPackage.deps}/share/emacs/site-lisp";
    in
    pkgs.writeShellScriptBin "neomacs" ''
      export emacsWithPackages_siteLisp=${siteLisp}
      export EMACSLOADPATH=${siteLisp}:''${EMACSLOADPATH-}
      exec ${lib.getExe inputs.neomacs.packages.${pkgs.stdenv.hostPlatform.system}.neomacs} "$@"
    '';
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = packages;
  };

  home.packages = [ neomacs ];

  xdg.configFile = {
    "emacs/early-init.el".source = tangle "early-init.el";
    "emacs/init.el".source = tangle "init.el";
  };
}
