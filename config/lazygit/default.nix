{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
  };
}
