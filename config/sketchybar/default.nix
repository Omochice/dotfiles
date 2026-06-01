{ pkgs, inputs, ... }:
let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  xdg.configFile = {
    sketchybar = {
      source = ./.;
    };
    "skt/ccusage.sh" = {
      text = ''
        #!/usr/bin/env bash
        set -ue
        COST="$(${pkgs.lib.getExe llm-pkgs.ccusage} --offline --json \
          | ${pkgs.lib.getExe pkgs.jq} -r '{ cost: .totals.totalCost, daily: .daily[-1].totalCost } | map_values((. * 100 | ceil ) / 100) | "$\(.cost) ($\(.daily)/d)"')"
        sketchybar -m --set $NAME label="$COST"
      '';
      executable = true;
    };

  };
}
