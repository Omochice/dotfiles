{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.trackpad.ForceClick = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to enable click only when push trackpad (not tap).
      '';
    };
  };
}
