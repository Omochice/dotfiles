{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.NSGlobalDomain.AppleActionOnDoubleClick = mkOption {
      type = types.nullOr types.string;
      default = null;
      description = ''
        Disable minimize on click title bar.
      '';
    };

    system.defaults.NSGlobalDomain.AppleMiniaturizeOnDoubleClick = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Disable minimize on click title bar.
      '';
    };
  };
}
