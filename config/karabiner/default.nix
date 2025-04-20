{ config, ... }:
{
  xdg.configFile = {
    "karabiner" = {
      source =
        "${config.home.homeDirectory}/dotfiles/config/karabiner" |> config.lib.file.mkOutOfStoreSymlink;
      recursive = true;
    };
  };
}
