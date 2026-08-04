{ config, ... }:
{
  xdg.configFile = {
    "colima/default/colima.yaml".source =
      "${config.my.dotfilesDir}/config/colima/default/colima.yaml" |> config.lib.file.mkOutOfStoreSymlink;
  };
}
