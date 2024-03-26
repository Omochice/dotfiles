{
  description = "Example Darwin system flake for Omochice";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      # environment.systemPackages =
      #   [ pkgs.vim
      #   ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      # programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      homebrew = {
        enable = true;
        casks = [
          "wezterm"
          "alt-tab"
          "vivaldi"
          "slack"
          "scroll-reverser"
          "gyazo"
          "karabiner-elements"
        ];
        taps = [
          "felixkratz/formulae"
          "koekeishiya/formulae"
          "aquaproj/aqua"
        ];
      };

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults = {
        NSGlobalDomain = {
          "com.apple.sound.beep.volume" = 0.0;
          InitialKeyRepeat = 25;
          KeyRepeat = 2;
          _HIHideMenuBar = true;
        };
        trackpad = {
          Clicking = true;
          #TrackpadMomentumScroll = true;
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
      };

      # not supported yet by system.defaults
      system.activationScripts.postActivation.text = ''
        # Disable minimize on click title bar
        defaults write "Apple Global Domain" AppleActionOnDoubleClick -string "None"

        defaults write com.apple.WindowManager HideDesktop -int 0
        defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -int 0

        # Momentum scroll
        defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 1
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll -int 1
      '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Mac
    darwinConfigurations."Mac" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Mac".pkgs;
  };
}
