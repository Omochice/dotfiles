{ config, ... }:
{
  xdg.configFile = {
    "aqua/aqua.yaml".source =
      "${config.home.homeDirectory}/dotfiles/config/aqua/aqua.yaml"
      |> config.lib.file.mkOutOfStoreSymlink;
  };
}
