{
  pkgs,
  ...
}:
let
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
    loadSessionVariables = true;
    # fzf runs preview commands with `$SHELL -c`, and the previews in
    # config.nu are written in nushell syntax, so SHELL has to name nu.
    extraEnv = ''
      $env.SHELL = "nu"
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
