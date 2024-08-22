{ config, lib, ... };

with lib;

{
  options. = {
    system.defaults.NSGlobalDomain.AppleActionOnDoubleClick = mkOption {
      type = types.nullOr types.string;
      default = null;
      description = ''
        Disable minimize on click title bar.
      '';
    };
  };
}
