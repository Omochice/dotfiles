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
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }@inputs:
    let
      system = "aarch64-darwin";
      configuration =
        { pkgs, ... }:
        {
          imports = [
            ./config/nix/modules/darwin/default.nix
            ./config/nix/applications/spotlight.nix
            ./config/nix/applications/homebrew.nix
          ];

          nix = {
            package = pkgs.nix;
            optimise.automatic = true;
            settings = {
              experimental-features = "nix-command flakes";
              max-jobs = 8;
            };
          };
          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          system = {
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 4;
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            defaults = {
              NSGlobalDomain = {
                "com.apple.sound.beep.volume" = 0.0;
                InitialKeyRepeat = 25;
                KeyRepeat = 2;
                _HIHideMenuBar = true;
                AppleActionOnDoubleClick = "None";
                AppleMiniaturizeOnDoubleClick = false;
                AppleMenuBarVisibleInFullscreen = false;
              };
              trackpad = {
                Clicking = true;
                TrackpadMomentumScroll = true;
              };
              trackpadBluetooth = {
                TrackpadMomentumScroll = true;
              };
              dock = {
                autohide = true;
                tilesize = 48;
                orientation = "left";
              };
              finder = {
                ShowPathbar = true;
                ShowStatusBar = true;
              };
              WindowManager = {
                HideDesktop = false;
                EnableStandardClickToShowDesktop = false;
              };
              CustomUserPreferences = {
                symbolichotkeys = {
                  AppleSymbolicHotKeys = import ./config/nix/system/darwin/symbolic-hotkeys.nix;
                };
              };
            };
          };
        };
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };
      darwinConfigurations = {
        omochice = nix-darwin.lib.darwinSystem { modules = [ configuration ]; };
      };
      homeConfigurations = {
        myHomeConfig = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = system;
          };
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./config/nix/home-manager/home.nix
          ];
        };
      };
      apps.${system}.update = {
        type = "app";
        program = toString (
          pkgs.writeShellScript "update-script" ''
            set -e
            echo "Updating flake..."
            nix flake update
            echo "Updating home-manager..."
            nix run home-manager -- switch --flake .#myHomeConfig --impure
            echo "Updating nix-darwin..."
            nix run nix-darwin -- switch --flake .#omochice
            echo "Update complete!"
          ''
        );
      };
    };
}
