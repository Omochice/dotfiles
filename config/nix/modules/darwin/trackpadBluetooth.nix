{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.trackpadBluetooth.TrackpadMomentumScroll = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to enable momentum scrolling on trackpad.
        Same as `defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll`.
      '';
    };
  };
}
