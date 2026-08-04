{
  pkgs,
  lib,
  ...
}:
let
  # SbarLua is a Lua 5.5 C module, so it is bundled into a matching interpreter
  # whose default search path already resolves require("sketchybar").
  lua = pkgs.lua5_5.withPackages (_: [ pkgs.sbarlua ]);
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    xdg.configFile = {
      "sketchybar/sketchybarrc" = {
        source = pkgs.replaceVars ./sketchybarrc {
          lua = "${lua}";
        };
        executable = true;
      };
      "sketchybar/paths.lua".source = pkgs.replaceVars ./paths.lua {
        ccusage = pkgs.lib.getExe pkgs.llm-pkgs.ccusage;
        jq = pkgs.lib.getExe pkgs.jq;
      };
      "sketchybar/colors.lua".source = ./colors.lua;
      "sketchybar/icons.lua".source = ./icons.lua;
      "sketchybar/init.lua".source = ./init.lua;
      "sketchybar/items".source = ./items;
    };
  };
}
