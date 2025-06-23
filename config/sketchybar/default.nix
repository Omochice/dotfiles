{ pkgs, ... }:
{
  xdg.configFile = {
    sketchybar = {
      source = ./.;
    };
    "skt/ccusage.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -ue
        COST="$(${pkgs.ccusage}/bin/ccusage --offline --json | ${pkgs.jq}/bin/jq -r '{ cost: .totals.totalCost, daily: .daily[-1].totalCost } | map_values((. * 100 | ceil ) / 100) | "$\(.cost) ($\(.daily)/d)"')"
        sketchybar -m --set $NAME label="$COST"
      '';
      executable = true;
    };

  };
}
