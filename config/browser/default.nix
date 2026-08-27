{ pkgs, ... }:
{
  home.sessionVariables.BROWSER =
    if pkgs.stdenv.hostPlatform.isDarwin then "open" else "vivaldi-stable";
}
