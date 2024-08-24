{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.NSGlobalDomain.AppleActionOnDoubleClick = mkOption {
      type = types.nullOr (
        types.enum [
          "Maximize"
          "Minimize"
          "None"
        ]
      );
      default = null;
      description = ''
        Action on double click title bar.
      '';
    };

    system.defaults.NSGlobalDomain.AppleMiniaturizeOnDoubleClick = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Disable minimize on click title bar.
      '';
    };

    system.defaults.NSGlobalDomain.AppleMenuBarVisibleInFullscreen = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = ''
        Show menu bar in full screen.
      '';
    };
  };
}
