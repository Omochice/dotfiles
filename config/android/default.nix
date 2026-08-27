{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionPath = lib.optional pkgs.stdenv.hostPlatform.isDarwin "${config.home.homeDirectory}/Library/Android/sdk/platform-tools";
}
