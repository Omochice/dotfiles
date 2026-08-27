{
  config,
  lib,
  pkgs,
  ...
}:
let
  # home-manager has no nushell counterpart of hm-session-vars.sh, so the
  # session variables are loaded here. Values that reference other variables
  # use sh expansion syntax, which nushell cannot evaluate, so they are left
  # to be inherited from the login shell.
  sessionVariables =
    config.home.sessionVariables
    |> lib.attrsets.filterAttrs (n: v: !(lib.strings.hasInfix "$" (toString v)));
  sessionPath =
    config.home.sessionPath |> map (p: ''("${p}" | path expand)'') |> lib.strings.concatStringsSep " ";
  nu_scripts = "${pkgs.nu_scripts}/share/nu_scripts";
in
{
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableFishIntegration = false;
  };
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    environmentVariables = sessionVariables;
    # fzf runs preview commands with `$SHELL -c`, and the previews in
    # config.nu are written in nushell syntax, so SHELL has to name nu.
    extraEnv = ''
      $env.SHELL = "nu"
      $env.PATH = ($env.PATH | append [${sessionPath}])
    '';
    # External command completion comes from carapace, which nushell asks on
    # demand, so no completion script has to be parsed at startup.
    extraConfig = ''
      use ${nu_scripts}/themes/nu-themes/catppuccin-mocha.nu
      $env.config.color_config = (catppuccin-mocha)
    '';
    shellAliases = {
      nu-open = "open";
      open = "^open";
    };
  };
}
