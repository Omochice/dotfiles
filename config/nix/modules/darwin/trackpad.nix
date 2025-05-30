{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.trackpad.TrackpadMomentumScroll = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to enable momentum scrolling on trackpad.
        Same as `defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll`.
      '';
    };
    system.defaults.trackpad.ForceClick = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to enable click only when push trackpad (not tap).
      '';
    };
  };
}
