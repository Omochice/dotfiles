{ pkgs }:
{
  global = {
    # keep-sorted start block=yes
    context7 = {
      type = "stdio";
      command = "${pkgs.context7-mcp}/bin/context7-mcp";
      args = [ ];
      env = { };
    };
    deepwiki-mcp = {
      type = "http";
      url = "https://mcp.deepwiki.com/mcp";
    };
    playwright = {
      type = "stdio";
      command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
      args = [ ];
      env = { };
    };
    # keep-sorted end
  };
}
