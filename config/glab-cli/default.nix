{ config, ... }:
{
  xdg.configFile = {
    "glab-cli/dummy" = {
      text = builtins.readFile ./aliases.yml;
      # FIXME: glab-cli needs set 600 to `aliases.yml`, but home-manager generate 444.
      onChange = ''
        ln -snf ${config.home.homeDirectory}/dotfiles/config/glab-cli/aliases.yml ${config.xdg.configHome}/glab-cli/aliases.yml
        chmod 600 ${config.xdg.configHome}/glab-cli/aliases.yml
      '';
    };
  };
}
