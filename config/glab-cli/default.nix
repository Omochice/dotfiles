{ config, ... }:
{
  xdg.configFile = {
    "glab-cli/aliases.yml".source =
      "${config.home.homeDirectory}/dotfiles/config/glab-cli/aliases.yml"
      |> config.lib.file.mkOutOfStoreSymlink;
  };
}
