{ pkgs, inputs, ... }:
let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # SbarLua is a Lua 5.5 C module, so it is bundled into a matching interpreter
  # whose default search path already resolves require("sketchybar").
  lua = pkgs.lua5_5.withPackages (_: [ pkgs.sbarlua ]);
in
{
  # SbarLua is only available on Darwin, so guard the whole module to keep the
  # Linux home-manager evaluation (CI) from forcing pkgs.sbarlua.
  xdg.configFile = pkgs.lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    "sketchybar/sketchybarrc" = {
      source = pkgs.replaceVars ./sketchybarrc {
        lua = "${lua}";
      };
      executable = true;
    };
    "sketchybar/paths.lua".source = pkgs.replaceVars ./paths.lua {
      ccusage = pkgs.lib.getExe llm-pkgs.ccusage;
      jq = pkgs.lib.getExe pkgs.jq;
    };
    "sketchybar/colors.lua".source = ./colors.lua;
    "sketchybar/icons.lua".source = ./icons.lua;
    "sketchybar/init.lua".source = ./init.lua;
    "sketchybar/items".source = ./items;
  };
}
