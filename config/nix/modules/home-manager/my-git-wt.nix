{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.my-git-wt;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.my-git-wt = {
    enable = lib.mkEnableOption "Enable My git-wt program.";
    package = lib.mkPackageOption pkgs "git-wt" { nullable = true; };
    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };
    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        basedir = "../{gitroot}-wt";
        copyignored = false;
        copymodified = false;
        nocopy = [ ];
        copy = [ ];
        # hook = [];
        nocd = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    programs.fish.interactiveShellInit = lib.mkIf cfg.enableFishIntegration (
      let
        initScript = pkgs.runCommand "git-wt-fish-init" { } ''
          ${lib.getExe cfg.package} --init fish > $out
        '';
      in
      builtins.readFile initScript
    );

    programs.git.settings.wt = lib.mkIf (cfg.settings != { }) cfg.settings;
  };
}
