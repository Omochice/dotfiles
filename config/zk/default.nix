{ ... }:
{
  programs.zk = {
    enable = true;
    settings = ./config.toml |> builtins.readFile |> builtins.fromTOML;
  };
}
