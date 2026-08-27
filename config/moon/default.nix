{ config, ... }:
{
  home.sessionPath = [ "${config.home.homeDirectory}/.moon/bin" ];
}
