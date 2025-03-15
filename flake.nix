# https://github.com/renovatebot/renovate/issues/29721
# Trick renovate into working: "github:NixOS/nixpkgs/nixpkgs-unstable"
{
  description = "Omochice dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
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
      };
      treefmt = treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (
        { ... }:
        {
          settings.global.excludes = [
            "**/aqua.yaml"
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
            pinact.enable = true;
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
        omochice = nix-darwin.lib.darwinSystem { modules = [ ./config/nix/nix-darwin/default.nix ]; };
      };
      homeConfigurations = {
        myHomeConfig = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            inherit inputs;
            inherit nur-packages;
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
          };
        in
        {
          "x86_64-linux" = {
            default = pkgs.mkShell {
              packages = [
                nixpkgs.legacyPackages.x86_64-linux.actionlint
                nur-packages.packages.x86_64-linux.ghalint
              ];
            };
          };
        };
      apps =
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          check-action-for = (
            system: {
              type = "app";
              program =
                ''
                  set -e
                  ${nixpkgs.legacyPackages.${system}.actionlint}/bin/actionlint --version
                  ${nixpkgs.legacyPackages.${system}.actionlint}/bin/actionlint
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
