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
      treefmt =
        system:
        treefmt-nix.lib.evalModule (pkgs-for system) (
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
      merge-attrs = nixpkgs.lib.foldr (a: b: nixpkgs.lib.attrsets.recursiveUpdate a b) { };
      run-as-on =
        system:
        let
          pkgs = pkgs-for system;
        in
        name: script: {
          type = "app";
          program = script |> pkgs.writeShellScript name |> toString;
        };
    in
    {
      formatter =
        (system: (treefmt system).config.build.wrapper)
        |> nixpkgs.lib.genAttrs [
          flake-utils.lib.system.x86_64-linux
          flake-utils.lib.system.aarch64-darwin
        ];
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
            username = builtins.getEnv "USER";
            homeDirectory = builtins.getEnv "HOME";
          };
          modules = [
            ./config/nix/home-manager/home.nix
          ];
        };
      };
      apps =
        [
          (
            (
              system:
              let
                pkgs = pkgs-for system;
                run-as = run-as-on system;
              in
              {
                check-action =
                  ''
                    set -e
                    ${pkgs.actionlint}/bin/actionlint --version
                    ${pkgs.actionlint}/bin/actionlint
                    ${pkgs.ghalint}/bin/ghalint --version
                    ${pkgs.ghalint}/bin/ghalint run
                    ${pkgs.zizmor}/bin/zizmor --version
                    ${pkgs.zizmor}/bin/zizmor .github/workflows/*.yml
                  ''
                  |> run-as "check-action";
              }
            )
            |> nixpkgs.lib.genAttrs [
              flake-utils.lib.system.x86_64-linux
              flake-utils.lib.system.aarch64-darwin
            ]
          )
          (
            (
              system:
              let
                pkgs = pkgs-for system;
                run-as = run-as-on system;
              in
              {
                update =
                  ''
                    set -e
                    echo "Updating nvfetcher"
                    ${pkgs.nvfetcher}/bin/nvfetcher
                    echo "Updating home-manager"
                    nix run github:nix-community/home-manager -- switch --flake .#omochice --impure |& ${pkgs.nix-output-monitor}/bin/nom
                    echo "Updating nix-darwin"
                    sudo nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice --impure |& ${pkgs.nix-output-monitor}/bin/nom
                    echo "Update complete!"
                  ''
                  |> run-as "update-script";
              }
            )
            |> nixpkgs.lib.genAttrs [
              flake-utils.lib.system.aarch64-darwin
            ]
          )
        ]
        |> merge-attrs;
    };
}
