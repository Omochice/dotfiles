# https://github.com/renovatebot/renovate/issues/29721
# Trick renovate into working: "github:NixOS/nixpkgs/nixpkgs-unstable"
{
  description = "Omochice dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nix-darwin,
      home-manager,
      treefmt-nix,
      flake-utils,
      nur-packages,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur-packages.overlays.default ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            settings.global.excludes = [
              "**/aqua.yaml"
              "_sources/**"
              "config/node2nix/**"
            ];
            programs = {
              # keep-sorted start block=yes
              deno = {
                enable = true;
                includes = [
                  "*.ts"
                  "*.js"
                ];
              };
              fish_indent.enable = true;
              formatjson5 = {
                enable = true;
                indent = 2;
              };
              keep-sorted.enable = true;
              nixfmt.enable = true;
              shfmt.enable = true;
              stylua = {
                enable = true;
                settings = ./config/stylua/stylua.toml |> builtins.readFile |> builtins.fromTOML;
              };
              taplo = {
                enable = true;
              };
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
        host = ./host.json |> builtins.readFile |> builtins.fromJSON;
      in
      {
        formatter = treefmt.config.build.wrapper;
        checks = {
          formatting = treefmt.config.build.check self;
        };
        legacyPackages = {
          darwinConfigurations = pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
            omochice = nix-darwin.lib.darwinSystem {
              modules = [ ./config/nix/nix-darwin/default.nix ];
              specialArgs = {
                inherit (host) user home;
              };
            };
          };
          homeConfigurations = {
            omochice = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs;
                inherit (host) user home;
              };
              modules = [
                ./config/nix/home-manager/home.nix
              ];
            };
          };
        };
        apps = {
          check-action =
            ''
              actionlint --version
              actionlint
              ghalint --version
              ghalint run
              zizmor --version
              zizmor .github/workflows .github/actions
            ''
            |> runAs "check-action" [
              pkgs.actionlint
              pkgs.ghalint
              pkgs.zizmor
            ];
          default =
            ''
              nix run .#sync
              nix run .#update
            ''
            |> runAs "default-script" [
              pkgs.nix
            ];
          sync =
            ''
              nix flake update
              nvfetcher
              cd config/node2nix
              node2nix -i node-packages.json
              cd -
            ''
            |> runAs "sync" [
              pkgs.nix
              pkgs.nvfetcher
              pkgs.node2nix
            ];
          update =
            ''
              jq -n --arg home "$HOME" --arg user "$USER" '{home: $home, user: $user}' > host.json
              git add host.json --force
              echo "Updating home-manager"
              nix run github:nix-community/home-manager -- switch --flake .#omochice |& nom
              ${
                ''
                  echo "Updating nix-darwin"
                  sudo nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice |& nom
                ''
                |> pkgs.lib.strings.optionalString pkgs.stdenv.isDarwin
              }
              echo "Update complete!"
              git reset -- host.json
            ''
            |> runAs "update-script" [
              pkgs.jq
              pkgs.git
              pkgs.nix
              pkgs.nix-output-monitor
            ];
        };
      }
    );
}
