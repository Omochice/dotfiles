{ pkgs, lib, ... }:
let
  extensions =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (name: _: name |> lib.strings.hasPrefix "gh-");
  runAs =
    name: runtimeInputs: text:
    pkgs.writeShellApplication {
      inherit name runtimeInputs text;
      excludeShellChecks = [
        "SC2016"
        "SC2059"
        "SC2086"
        "SC2181"
      ];
    };
  readShellExetension =
    name: depends: builtins.readFile "${extensions.${name}.src}/${name}" |> runAs name depends;
  gh-extensions = [
    (readShellExetension "gh-q" [
      pkgs.gh
      pkgs.fzf
      pkgs.coreutils
    ])
    (readShellExetension "gh-fzgist" [
      pkgs.gh
      pkgs.fzf
      pkgs.gawk
      pkgs.findutils
    ])
    (readShellExetension "gh-userfetch" [
      pkgs.jq
      pkgs.coreutils
    ])
  ];
in
{
  xdg.configFile = {
    "gh/config.yml".source = ./config.yml;
  };
  xdg.dataFile."gh/extensions" = {
    source = pkgs.linkFarm "gh-extensions" (
      gh-extensions
      |> builtins.map (p: {
        name = p.name;
        path = "${p}/bin";
      })
    );
  };
}
