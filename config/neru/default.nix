{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.neru.homeManagerModules.default ];

  services.neru = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    enable = true;
    package = inputs.neru.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      hotkeys = {
        "Primary+Shift+E" = "hints";
        "Primary+Shift+Space" = "hints --action left_click";
      };
      scroll.invert_scroll = true;
    };
  };
}
