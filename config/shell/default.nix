{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.nix-profile/bin"
    "${config.home.homeDirectory}/.moon/bin"
  ]
  ++ lib.optional isDarwin "${config.home.homeDirectory}/Library/Android/sdk/platform-tools";
  home.sessionVariables = {
    DEVBOX_NO_PROMPT = "true";
    devbox_no_prompt = "true";
  }
  // lib.optionalAttrs isDarwin { BROWSER = "open"; }
  // lib.optionalAttrs isLinux { BROWSER = "vivaldi-stable"; };
  home.shellAliases = {
    ":q" = "exit";
    cat = "bat";
    gl = "glab";
    ls = "lsd";
    tree = "lsd --tree";
    ptpython = "ptpython --vi";
    ptipython = "ptipython --vi";
  }
  // lib.optionalAttrs isDarwin {
    shutdown = "sudo shutdown -h now";
    reboot = "sudo reboot";
    lock = "pmset displaysleepnow";
  }
  // lib.optionalAttrs isLinux {
    shutdown = "shutdown -h now";
    pbcopy = "xsel --clipboard --input";
    pbpaste = "xsel --clipboard --output";
    yay = "paru";
  };
}
