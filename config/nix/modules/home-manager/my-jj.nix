{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.my-jj;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.my-jj = {
    enable = lib.mkEnableOption "Enable My jj program.";
    package = lib.mkPackageOption pkgs "jujutsu" { nullable = true; };
    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = {
        ui.editor = "nvim";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."jj/config.toml" = lib.mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "jj-config" cfg.settings;
    };
  };
}
