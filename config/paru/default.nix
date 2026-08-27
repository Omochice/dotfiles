{ lib, pkgs, ... }:
{
  home.shellAliases = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux { yay = "paru"; };
}
