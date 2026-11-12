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
  tree-sitter-moonbit = pkgs.callPackage ./tree-sitter-moonbit/default.nix {
    source = sources.tree-sitter-moonbit;
  };
in
{
  inherit tree-sitter-moonbit;
  neovim-omochice = pkgs.callPackage ./neovim/default.nix {
    source = sources.neovim;
    inherit tree-sitter-moonbit;
  };
  ast-grep-omochice = pkgs.callPackage ./ast-grep/default.nix { inherit tree-sitter-moonbit; };
  skk-jisyo-l-utf8 = pkgs.callPackage ./skk-jisyo-l-utf8/default.nix { };
}
