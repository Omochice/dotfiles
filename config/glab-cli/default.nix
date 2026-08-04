{ config, ... }:
{
  xdg.configFile = {
    "glab-cli/aliases.yml".source =
      "${config.my.dotfilesDir}/config/glab-cli/aliases.yml" |> config.lib.file.mkOutOfStoreSymlink;
  };
}
