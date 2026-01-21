{ ... }:
{
  programs.starship = {
    enable = true;
    settings = ./config.toml |> builtins.readFile |> fromTOML;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };
}
