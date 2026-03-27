{ pkgs, specialArgs, ... }:
let
  inherit (specialArgs) user home;
in
{
  imports = [
    ../modules/darwin/default.nix
    ../applications/spotlight.nix
    ../applications/homebrew.nix
    ../applications/yabai.nix
  ];
  nix = {
    # Auto upgrade nix package and the daemon service.
    enable = true;
    package = pkgs.nix;
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes pipe-operators";
      max-jobs = 8;
      substituters = [
        "https://omochice.cachix.org"
      ];
      trusted-public-keys = [
        "omochice.cachix.org-1:d+cdfbGVPgtxxdGSkGf3hhaCdfziMtZ6FSHUWxwUTo8="
      ];
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
      packages = with pkgs; [
        go-ios
      ];
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
      CustomUserPreferences.symbolichotkeys.AppleSymbolicHotKeys = import ../system/darwin/symbolic-hotkeys.nix;
      dock.autohide = true;
      dock.mineffect = "scale";
      dock.no-bouncing = true;
      dock.orientation = "left";
      dock.tilesize = 48;
      finder.AppleShowAllExtensions = true;
      finder.AppleShowAllFiles = true;
      finder.ShowPathbar = true;
      finder.ShowStatusBar = true;
      NSGlobalDomain."com.apple.keyboard.fnState" = true;
      NSGlobalDomain."com.apple.sound.beep.volume" = 0.0;
      NSGlobalDomain._HIHideMenuBar = true;
      NSGlobalDomain.AppleActionOnDoubleClick = "None";
      NSGlobalDomain.AppleMenuBarVisibleInFullscreen = false;
      NSGlobalDomain.AppleMiniaturizeOnDoubleClick = false;
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowAllFiles = true;
      NSGlobalDomain.InitialKeyRepeat = 25;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain.SLSMenuBarUseBlurredAppearance = true;
      PowerChime.ChimeOnAllHardware = false;
      PowerChime.ChimeOnNoHardware = true;
      spaces.spans-displays = false;
      trackpad.Clicking = true;
      trackpad.ForceClick = false;
      trackpad.TrackpadMomentumScroll = true;
      trackpadBluetooth.TrackpadMomentumScroll = true;
      universalaccess.reduceMotion = false;
      WindowManager.EnableStandardClickToShowDesktop = false;
      WindowManager.HideDesktop = false;
      # keep-sorted end
    };
  };
}
