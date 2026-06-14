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

  # karabiner-elements rewrites this file at runtime, so it lives outside the
  # store as a mutable copy rather than a read-only store symlink.
  configPath = "${config.home.homeDirectory}/dotfiles/config/karabiner/karabiner.json";
in
{
  xdg.configFile = {
    "karabiner" = {
      source =
        "${config.home.homeDirectory}/dotfiles/config/karabiner" |> config.lib.file.mkOutOfStoreSymlink;
      recursive = true;
    };
  };

  home.activation.karabinerJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run cp ${karabinerJson} "${configPath}"
    run chmod u+w "${configPath}"
  '';
}
