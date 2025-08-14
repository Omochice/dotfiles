{ config, ... }:
{
  xdg.configFile = {
    "colima/default/colima.yaml".source =
      "${config.home.homeDirectory}/dotfiles/config/colima/default/colima.yaml"
      |> config.lib.file.mkOutOfStoreSymlink;
  };
}
