{ pkgs, specialArgs, ... }:
let
  inherit (specialArgs) user home;
in
{
  imports = [
    ../modules/darwin/default.nix
    ../applications/spotlight.nix
    ../applications/homebrew.nix
  ];
  nix = {
    # Auto upgrade nix package and the daemon service.
    enable = true;
    package = pkgs.nix;
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes pipe-operators";
      max-jobs = 8;
    };
  };
  # The platform the configuration will be used on.
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
  users = {
    users.${user} = {
      inherit home;
      uid = pkgs.lib.mkDefault 501;
      shell = pkgs.fish;
    };
    knownUsers = [ user ];
  };
  programs.fish.enable = true;
  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
    primaryUser = user;
    defaults = {
      # keep-sorted start block=yes case=no
      CustomUserPreferences = {
        symbolichotkeys = {
          AppleSymbolicHotKeys = import ../system/darwin/symbolic-hotkeys.nix;
        };
      };
      dock = {
        # keep-sorted start
        autohide = true;
        mineffect = "scale";
        no-bouncing = true;
        orientation = "left";
        tilesize = 48;
        # keep-sorted end
      };
      finder = {
        # keep-sorted start
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        # keep-sorted end
      };
      NSGlobalDomain = {
        # keep-sorted start
        "com.apple.keyboard.fnState" = true;
        "com.apple.sound.beep.volume" = 0.0;
        AppleActionOnDoubleClick = "None";
        AppleMenuBarVisibleInFullscreen = false;
        AppleMiniaturizeOnDoubleClick = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 25;
        KeyRepeat = 2;
        _HIHideMenuBar = true;
        # keep-sorted end
      };
      PowerChime = {
        # keep-sorted start
        ChimeOnAllHardware = false;
        ChimeOnNoHardware = true;
        # keep-sorted end
      };
      spaces.spans-displays = false;
      trackpad = {
        # keep-sorted start
        Clicking = true;
        ForceClick = false;
        TrackpadMomentumScroll = true;
        # keep-sorted end
      };
      trackpadBluetooth = {
        TrackpadMomentumScroll = true;
      };
      universalaccess.reduceMotion = false;
      WindowManager = {
        # keep-sorted start
        EnableStandardClickToShowDesktop = false;
        HideDesktop = false;
        # keep-sorted end
      };
      # keep-sorted end
    };
  };
}
