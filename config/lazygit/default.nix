{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    package = pkgs.nur.lazygit;
    settings = ./config.toml |> builtins.readFile |> fromTOML;
  };
}
