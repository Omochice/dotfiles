{
  pkgs,
  inputs,
  ...
}:
let
  org-babel = inputs.org-babel.lib;

  # nskk has no option for the dictionary coding and misdetects the EUC-JP original.
  skkJisyoL = pkgs.runCommand "SKK-JISYO.L.utf8" { nativeBuildInputs = [ pkgs.nkf ]; } ''
    nkf -w ${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L > $out
  '';

  tangle =
    tangleArg:
    pkgs.writeText tangleArg (
      builtins.replaceStrings [ "@skkJisyoL@" ] [ "${skkJisyoL}" ] (
        org-babel.tangleOrgBabel {
          languages = [ "emacs-lisp" ];
          inherit tangleArg;
        } (builtins.readFile ./config.org)
      )
    );

  nskk =
    epkgs:
    let
      source = pkgs.dotfiles-sources.nskk;
    in
    epkgs.trivialBuild {
      pname = "nskk";
      version = "0-unstable-${source.date}";
      src = "${source.src}/src";
    };

  packages =
    epkgs: with epkgs; [
      (nskk epkgs)
      # keep-sorted start
      browse-at-remote
      clipetty
      consult
      corfu
      corfu-terminal
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
in
{
  programs.emacs = {
    enable = true;
    package = inputs.neomacs.packages.${pkgs.stdenv.hostPlatform.system}.neomacs;
    extraPackages = packages;
  };

  xdg.configFile = {
    "emacs/early-init.el".source = tangle "early-init.el";
    "emacs/init.el".source = tangle "init.el";
  };
}
