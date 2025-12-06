# https://github.com/renovatebot/renovate/issues/29721
# Trick renovate into working: "github:NixOS/nixpkgs/nixpkgs-unstable"
{
  description = "Omochice dotfiles";

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
                nix-doom-emacs-unstraightened.homeModule
                ./config/nix/home-manager/home.nix
              ];
            };
          };
        };
        apps = {
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
              nix run .#update
              nix run .#mcp-setting
            ''
            |> runAs "default-script" [
              pkgs.nix
            ];
          mcp-setting =
            mcpCommands
            |> runAs "claude-code-setting-mcp" [
              pkgs.claude-code
            ];
          sync =
            ''
              nvfetcher
            ''
            |> runAs "sync" [ pkgs.nvfetcher ];
          update =
            ''
              jq -n --arg home "$HOME" --arg user "$USER" '{home: $home, user: $user}' > host.json
              git add host.json --force
              trap 'git reset -- host.json && rm host.json' EXIT
              echo "Updating home-manager"
              nix run github:nix-community/home-manager -- switch --flake .#omochice -b backup |& nom
              ${
                ''
                  echo "Updating nix-darwin"
                  sudo nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice |& nom
                ''
                |> pkgs.lib.strings.optionalString pkgs.stdenv.isDarwin
              }
              echo "Update complete!"
            ''
            |> runAs "update-script" [
              pkgs.jq
              pkgs.git
              pkgs.nix
              pkgs.nix-output-monitor
            ];
          install-check =
            ''
              jq -n --arg home "$HOME" --arg user "$USER" '{home: $home, user: $user}' > host.json
              git add host.json --force
              trap 'git reset -- host.json && rm host.json' EXIT
              nix run github:nix-community/home-manager -- switch --flake .#omochice -b backup
            ''
            |> runAs "update-script" [
              pkgs.jq
              pkgs.git
              pkgs.nix
            ];
        };
      }
    );
}
