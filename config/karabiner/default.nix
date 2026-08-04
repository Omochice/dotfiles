{
  config,
  pkgs,
  lib,
  ...
}:
let
  k = import ./lib.nix { };
  profiles = import ./profile.nix {
    inherit k;
    inherit pkgs;
  };

  karabinerJson = pkgs.writeText "karabiner.json" (builtins.toJSON profiles);

  configDir = "${config.xdg.configHome}/karabiner";
  jsonPath = "${configDir}/karabiner.json";
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    xdg.configFile."karabiner/queries".source = ./queries;
    home.activation.karabinerJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${lib.escapeShellArg configDir}
      run cp ${karabinerJson} ${lib.escapeShellArg jsonPath}
      run chmod u+w ${lib.escapeShellArg jsonPath}
    '';
  };
}
