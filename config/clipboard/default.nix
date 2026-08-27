{ lib, pkgs, ... }:
{
  # macOS ships pbcopy/pbpaste; on Linux the same names are given to xsel.
  home.shellAliases = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    pbcopy = "xsel --clipboard --input";
    pbpaste = "xsel --clipboard --output";
  };
}
