{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = ./config.toml |> builtins.readFile |> fromTOML;
  };
}
