{ config, lib, ... }:

with lib;

{
  options = {
    system.defaults.WindowManager.HideDesktop = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = lib.mkDoc ''
        Whether to hide the desktop icons.
      '';
    };

    system.defaults.WindowManager.EnableStandardClickToShowDesktop = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = lib.mkDoc ''
        Whether to enable standard click to show desktop.
      '';
    };
  };
}
