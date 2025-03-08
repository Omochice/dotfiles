{ ... }:
{
  programs.starship = {
    enable = true;
    settings = ./config.toml |> builtins.readFile |> builtins.fromTOML;
    enableNushellIntegration = true;
  };
}
