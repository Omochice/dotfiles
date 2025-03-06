{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = ./config.toml |> (builtins.readFile) |> builtins.fromTOML;
  };
}
