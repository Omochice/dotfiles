{ pkgs }:
let
  sources = import ../_sources/generated.nix {
    inherit (pkgs)
      fetchgit
      fetchurl
      fetchFromGitHub
      dockerTools
      ;
  };
in
{
  neovim-omochice = pkgs.callPackage ./neovim/default.nix { inherit sources; };
}
