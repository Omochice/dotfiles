# https://github.com/renovatebot/renovate/issues/29721
# Trick renovate into working: "github:NixOS/nixpkgs/nixpkgs-unstable"
{
  description = "Omochice dotfiles";

  nixConfig = {
    extra-substituters = [
      "https://omochice.cachix.org"
    ];
    extra-trusted-public-keys = [
      "omochice.cachix.org-1:d+cdfbGVPgtxxdGSkGf3hhaCdfziMtZ6FSHUWxwUTo8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
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
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
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
      mcp-servers-nix,
      nix-doom-emacs-unstraightened,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            mcp-servers-nix.overlays.default
            nur-packages.overlays.default
            (final: prev: import ./pkgs/default.nix { pkgs = final; })
          ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            settings.global.excludes = [
              "**/aqua.yaml"
              "_sources/**"
              # It will update by colima when `colima start`
              "config/colima/**.yaml"
            ];
            settings.formatter = {
              # keep-sorted start block=yes
              rumdl = {
                command = "${pkgs.rumdl}/bin/rumdl";
                options = [
                  "fmt"
                  "--config"
                  (builtins.toString ./config/rumdl/rumdl.toml)
                ];
                includes = [ "*.md" ];
              };
              # keep-sorted end
            };
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
        mcpCommands =
          import ./config/claude/mcp-servers.nix { inherit pkgs; }
          |> builtins.getAttr "global"
          |> builtins.mapAttrs (
            name: value:
            if value.type == "http" || value.type == "stdio" then
              ''
                claude mcp remove --scope user ${name} || true
                claude mcp add-json --scope user ${name} '${value |> builtins.toJSON}'
              ''
            else
              builtins.throw "Unknown mcp server type: ${value.type}"
          )
          |> builtins.attrValues
          |> builtins.concatStringsSep "\n";
        host = ./host.json |> builtins.readFile |> builtins.fromJSON;
        mcp-setting = pkgs.writeShellApplication {
          name = "mcp-setting";
          runtimeInputs = [ pkgs.claude-code ];
          text = mcpCommands;
        };
        update = pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = [
            pkgs.jq
            pkgs.git
            pkgs.nix-output-monitor
            home-manager.packages.${system}.home-manager
          ]
          ++ (pkgs.lib.optional pkgs.stdenv.isDarwin nix-darwin.packages.${system}.darwin-rebuild);
          text = ''
            jq -n --arg home "$HOME" --arg user "$USER" '{home: $home, user: $user}' > host.json
            git add host.json --force
            trap 'git reset -- host.json && rm host.json' EXIT
            echo "Updating home-manager"
            home-manager switch --flake .#omochice -b backup |& nom
          ''
          + (
            ''
              echo "Updating nix-darwin"
              sudo darwin-rebuild switch --flake .#omochice |& nom
            ''
            |> pkgs.lib.strings.optionalString pkgs.stdenv.isDarwin
          );
        };
      in
      {
        # keep-sorted start block=yes
        apps = {
          # keep-sorted start block=yes
          check-action =
            ''
              actionlint
              ghalint run
              zizmor .github/workflows .github/actions
            ''
            |> runAs "check-action" [
              pkgs.actionlint
              pkgs.ghalint
              pkgs.zizmor
            ];
          default =
            ''
              update
              mcp-setting
            ''
            |> runAs "default-script" [
              update
              mcp-setting
            ];
          install-check =
            ''
              jq -n --arg home "$HOME" --arg user "$USER" '{home: $home, user: $user}' > host.json
              git add host.json --force
              trap 'git reset -- host.json && rm host.json' EXIT
              home-manager switch --flake .#omochice -b backup
            ''
            |> runAs "update-script" [
              pkgs.jq
              pkgs.git
              home-manager.packages.${system}.home-manager
            ];
          mcp-setting = {
            type = "app";
            program = "${mcp-setting}/bin/mcp-setting";
          };
          sync =
            ''
              nvfetcher
            ''
            |> runAs "sync" [ pkgs.nvfetcher ];
          update = {
            type = "app";
            program = "${update}/bin/update";
          };
          validate-renovate-config =
            ''
              renovate-config-validator --strict renovate.json5
            ''
            |> runAs "validate-renovate-config" [
              pkgs.renovate
            ];
          # keep-sorted end
        };
        checks = {
          formatting = treefmt.config.build.check self;
        };
        formatter = treefmt.config.build.wrapper;
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
                nix-doom-emacs-unstraightened.homeModule
                ./config/nix/home-manager/home.nix
              ];
            };
          };
        };
        # keep-sorted end
      }
    );
}
