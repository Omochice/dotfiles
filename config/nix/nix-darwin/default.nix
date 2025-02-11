{ pkgs, ... }:
{
  imports = [
    ../modules/darwin/default.nix
    ../applications/spotlight.nix
    ../applications/homebrew.nix
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
    defaults = {
      NSGlobalDomain = {
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.keyboard.fnState" = true;
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
        no-bouncing = true;
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
          AppleSymbolicHotKeys = import ../system/darwin/symbolic-hotkeys.nix;
        };
      };
      PowerChime = {
        ChimeOnAllHardware = false;
      };
    };
  };
}
