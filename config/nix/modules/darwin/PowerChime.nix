{ lib, ... }:
with lib;
{
  options = {
    system.defaults.PowerChime.ChimeOnAllHardware = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Whether or not to chime when star.
        Same as `defaults write com.apple.PowerChime ChimeOnAllHardware`.
      '';
    };
  };
}
