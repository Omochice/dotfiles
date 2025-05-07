{ pkgs, ... }:
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
  nixpkgs.hostPlatform = "aarch64-darwin";
  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
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
        no-bouncing = true;
        orientation = "left";
        tilesize = 48;
        # keep-sorted end
      };
      finder = {
        # keep-sorted start
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
