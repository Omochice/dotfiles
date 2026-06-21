{
  config,
  pkgs,
  lib,
  ...
}:
let
  k = import ./lib.nix { };
  profiles = import ./profile.nix { inherit k; };

  karabinerJson = pkgs.writeText "karabiner.json" (builtins.toJSON profiles);

  configDir = "${config.xdg.configHome}/karabiner";
  jsonPath = "${configDir}/karabiner.json";
in
{
  # The generated config invokes these at runtime via
  # `deno run -A ~/.config/karabiner/queries/...`, so they must exist in the
  # live config directory. They are immutable, so a read-only store symlink is
  # enough and keeps the path independent of the repository location.
  xdg.configFile."karabiner/queries".source = ./queries;

  # karabiner-elements rewrites karabiner.json at runtime, so it must be a
  # mutable copy in the live config directory rather than a read-only store
  # symlink.
  home.activation.karabinerJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg configDir}
    run cp ${karabinerJson} ${lib.escapeShellArg jsonPath}
    run chmod u+w ${lib.escapeShellArg jsonPath}
  '';
}
