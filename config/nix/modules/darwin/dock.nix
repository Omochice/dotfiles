{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.dock.no-bouncing = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to bounce to notify application is launch.
        Same as `defaults write com.apple.dock no-bouncing`.
      '';
    };
  };
}
