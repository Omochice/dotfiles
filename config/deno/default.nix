{ pkgs, ... }:
{
  # NOTE: To work yabai keybinddings with karabiner
  # It expected location of deno binary at ~/.deno/bin/deno
  home.file.".deno/bin/deno".source = "${pkgs.deno}/bin/deno";
}
