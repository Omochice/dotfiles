{
  description = "Omochice dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          imports = [
            ./config/nix/modules/darwin/default.nix
            ./config/nix/applications/spotlight.nix
            ./config/nix/applications/yabai.nix
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
            activationScripts = {
              postActivation.text = ''
                ${pkgs.deno}/bin/deno run -A /Users/omochice/.config/karabiner/mod.ts ${pkgs.yabai}/bin /Users/omochice/.config/karabiner/karabiner.json
              '';
            };
          };
        };
    in
    {
      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };
      darwinConfigurations = {
        omochice = nix-darwin.lib.darwinSystem { modules = [ configuration ]; };
      };
    };
}
