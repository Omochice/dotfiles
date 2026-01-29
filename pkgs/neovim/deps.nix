{
  lib,
  neovim-src,
  pkgs,
}:
let
  stdenv = if pkgs.stdenv.isDarwin then pkgs.clangStdenv else pkgs.useMoldLinker pkgs.clangStdenv;

  moldRC =
    name: env:
    pkgs.runCommandWith {
      inherit name stdenv;
      runLocal = false;
      derivationArgs = env;
    };
  deps =
    "${neovim-src}/cmake.deps/deps.txt"
    |> builtins.readFile
    |> builtins.split "[\n]"
    |> builtins.filter builtins.isString
    |> builtins.map (builtins.match "([0-9A-Z_]+)_(URL|SHA256) (.+)")
    |> builtins.filter builtins.isList
    |> builtins.map (m: {
      "${lib.toLower (builtins.elemAt m 0)}" = {
        "${lib.toLower (builtins.elemAt m 1)}" = builtins.elemAt m 2;
      };
    })
    |> builtins.foldl' lib.recursiveUpdate { }
    |> lib.mapAttrs' (
      name: value: {
        name = "${name}/${builtins.baseNameOf value.url}";
        value = builtins.fetchurl value;
      }
    )
    |> pkgs.linkFarm "deps";
  buildpath = builtins.path {
    path = neovim-src;
    name = "neovim-deps-build-path";
    filter =
      path: type:
      let
        list = builtins.filter builtins.isString (builtins.split "/" path);
        base = builtins.elemAt list 4;
      in
      base == "Makefile" || base == "cmake" || base == "cmake.deps";
    recursive = true;
  };
in
moldRC "neovim-deps"
  {
    buildInputs = [ pkgs.cmake ];
  }
  ''
    cp -a ${buildpath}/* .
    mkdir -p .deps/build
    cp -a ${deps} .deps/build/downloads
    make -j$NIX_BUILD_CORES deps
    cp -a .deps $out
  ''
