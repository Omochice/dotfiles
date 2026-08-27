{ lib, pkgs, ... }:
let
  # Homebrew is installed outside nix, so whether it exists is only known at
  # runtime; this is the one piece of shell environment that stays conditional.
  prefix =
    if pkgs.stdenv.hostPlatform.isDarwin then "/opt/homebrew" else "/home/linuxbrew/.linuxbrew";
in
{
  programs.fish.interactiveShellInit = lib.mkBefore ''
    test -e ${prefix}/bin/brew && eval (${prefix}/bin/brew shellenv)
  '';
  # `brew shellenv` has no nushell output, so the variables it would set are
  # written out directly. path_helper is skipped: it only reorders /etc/paths
  # entries, which nushell already has from the login shell.
  programs.nushell.extraEnv = ''
    if ("${prefix}/bin/brew" | path exists) {
      $env.HOMEBREW_PREFIX = "${prefix}"
      $env.HOMEBREW_CELLAR = "${prefix}/Cellar"
      $env.HOMEBREW_REPOSITORY = "${prefix}"
      $env.INFOPATH = "${prefix}/share/info"
      $env.PATH = ($env.PATH | prepend ["${prefix}/bin" "${prefix}/sbin"] | uniq)
    }
  '';
}
