{
  pkgs,
  ...
}:
let
  baseHint = {
    command = if pkgs.stdenv.isDarwin then "open" else "xdg-open";
    post_processing = true;
    persist = false;
    mouse.enabled = true;
  };
in
{
  programs.alacritty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.alacritty;
    settings = {
      window.opacity = 0.8;
      window.option_as_alt = "Both";
      hints.enabled = [
        (
          baseHint
          // {
            regex = pkgs.lib.trim ''
              (ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\u0000-\u001F\u007F-\u009F<>"\\s{-}\\^⟨⟩`\\\\]+
            '';
          }
        )
        (
          baseHint
          // {
            hyperlinks = true;
          }
        )
      ];
      font = {
        size = 20;
        normal = {
          family = "Firge35Nerd Console";
          style = "Regular";
        };
        bold = {
          family = "Firge35Nerd Console";
          style = "Bold";
        };
        italic = {
          family = "Firge35Nerd Console";
          style = "Italic";
        };
        bold_italic = {
          family = "Firge35Nerd Console";
          style = "Bold Italic";
        };
      };
      terminal.shell = {
        program = "${pkgs.lib.getExe pkgs.tmux}";
        args = [
          "new-session"
          "-A"
          "-D"
          "-s"
          "main"
        ];
      };
    };
  };
}
