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
  neovim-custom = pkgs.callPackage ./neovim.nix { inherit sources; };
}
