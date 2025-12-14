{
  description = "sample description";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flake-utils,
      nur-packages,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            nur-packages.overlays.default
          ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            settings.global.excludes = [ ];
            settings.formatter = {
              # keep-sorted start block=yes
              rumdl = {
                command = "${pkgs.rumdl}/bin/rumdl";
                options = [ "fmt" ];
                includes = [ "*.md" ];
              };
              # keep-sorted end
            };
            programs = {
              # keep-sorted start block=yes
              keep-sorted.enable = true;
              nixfmt.enable = true;
              toml-sort.enable = true;
              yamlfmt = {
                enable = true;
                settings = {
                  formatter = {
                    type = "basic";
                    retain_line_breaks_single = true;
                  };
                };
              };
              # keep-sorted end
            };
          }
        );
        runAs =
          name: runtimeInputs: text:
          let
            program = pkgs.writeShellApplication {
              inherit name runtimeInputs text;
            };
          in
          {
            type = "app";
            program = "${program}/bin/${name}";
          };
        devPackages = rec {
          # keep-sorted start block=yes
          actions = with pkgs; [
            actionlint
            ghalint
            zizmor
          ];
          # keep-sorted end
          default = [
            treefmt.config.build.wrapper
          ]
          ++ actions;
        };
      in
      {
        # keep-sorted start block=yes
        apps = {
          check-action = pkgs.lib.pipe ''
            actionlint
            ghalint run
            zizmor .github
          '' [ (runAs "check-action" devPackages.actions) ];
        };
        checks = {
          formatting = treefmt.config.build.check self;
        };
        devShells = pkgs.lib.pipe devPackages [
          (pkgs.lib.attrsets.mapAttrs (name: buildInputs: pkgs.mkShell { inherit buildInputs; }))
        ];
        formatter = treefmt.config.build.wrapper;
        # keep-sorted end
      }
    );
}
