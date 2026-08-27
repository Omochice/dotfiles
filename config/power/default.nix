{ lib, pkgs, ... }:
{
  home.shellAliases =
    if pkgs.stdenv.hostPlatform.isDarwin then
      {
        shutdown = "sudo shutdown -h now";
        reboot = "sudo reboot";
        lock = "pmset displaysleepnow";
      }
    else
      {
        shutdown = "shutdown -h now";
      };
}
