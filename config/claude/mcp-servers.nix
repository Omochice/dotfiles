{ pkgs }:
{
  global = {
    context7 = {
      type = "stdio";
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
      args = [ ];
      env = { };
    };
  };
}
