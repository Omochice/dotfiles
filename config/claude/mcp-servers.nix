{ pkgs }:
{
  global = {
    context7 = {
      type = "stdio";
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
      args = [ ];
      env = { };
    };
    playwright = {
      type = "stdio";
      command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      args = [ ];
      env = { };
    };
  };
}
