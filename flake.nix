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
    let
      system = "aarch64-darwin";
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
            formatjson5 = {
              enable = true;
              indent = 2;
            };
            keep-sorted.enable = true;
            nixfmt.enable = true;
            pinact = {
              enable = true;
              update = false;
            };
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
    in
    {
      formatter = {
        "${system}" = treefmt.config.build.wrapper;
      };
      darwinConfigurations = {
        omochice = nix-darwin.lib.darwinSystem {
          modules = [ ./config/nix/nix-darwin/default.nix ];
          specialArgs = {
            username = "Omochice";
          };
        };
      };
      homeConfigurations = {
        myHomeConfig = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./config/nix/home-manager/home.nix
          ];
        };
      };
      devShells =
        let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nur-packages.overlays.default ];
          };
        in
        {
          "x86_64-linux" = {
            default = pkgs.mkShell {
              packages = [
                pkgs.actionlint
                pkgs.ghalint
              ];
            };
          };
        };
      apps =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nur-packages.overlays.default ];
          };
          check-action-for = (
            system: {
              type = "app";
              program =
                ''
                  set -e
                  ${pkgs.actionlint}/bin/actionlint --version
                  ${pkgs.actionlint}/bin/actionlint
                  ${pkgs.ghalint}/bin/ghalint --version
                  ${pkgs.ghalint}/bin/ghalint run
                ''
                |> pkgs.writeShellScript "check-action-script"
                |> toString;
            }
          );
        in
        {
          "x86_64-linux" = {
            check-action = check-action-for "x86_64-linux";
          };
          "aarch64-darwin" = {
            update = {
              type = "app";
              program =
                ''
                  set -e
                  echo "Updating home-manager..."
                  nix run home-manager -- switch --flake .#myHomeConfig --impure |& ${pkgs.nix-output-monitor}/bin/nom
                  echo "Updating nix-darwin..."
                  nix run nix-darwin -- switch --flake .#omochice
                  echo "Update complete!"
                ''
                |> pkgs.writeShellScript "update-script"
                |> toString;
            };
            check-action = check-action-for "aarch64-darwin";
          };
        };
    };
}
