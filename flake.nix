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
      pkgs-for =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ nur-packages.overlays.default ];
        };
      pkgs = pkgs-for system;
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
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          };
        };
      };
      homeConfigurations = {
        omochice = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
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
          pkgs = pkgs-for "x86_64-linux";
        in
        {
          "x86_64-linux" = {
            default = pkgs.mkShell {
              packages = [
                pkgs.actionlint
                pkgs.ghalint
                pkgs.zizmor
              ];
            };
          };
        };
      apps =
        let
          pkgs = pkgs-for system;
          check-action-for = (
            system:
            let
              pkgs = pkgs-for system;
            in
            {
              type = "app";
              program =
                ''
                  set -e
                  ${pkgs.actionlint}/bin/actionlint --version
                  ${pkgs.actionlint}/bin/actionlint
                  ${pkgs.ghalint}/bin/ghalint --version
                  ${pkgs.ghalint}/bin/ghalint run
                  ${pkgs.zizmor}/bin/zizmor --version
                  ${pkgs.zizmor}/bin/zizmor .github/workflows/*.yml
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
                  nix run github:nix-community/home-manager -- switch --flake .#omochice --impure |& ${pkgs.nix-output-monitor}/bin/nom
                  echo "Updating nix-darwin..."
                  nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice --impure
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
