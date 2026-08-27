{
  config,
  lib,
  pkgs,
  ...
}:
let
  plugins =
    pkgs.dotfiles-sources
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix "fish-")
    |> builtins.attrValues
    |> builtins.filter (x: (builtins.typeOf x) == "set" && x ? "pname")
    |> map (x: {
      name = x.pname |> lib.strings.removePrefix "fish-";
      src = x.src;
    });

  parse-fish-function = (
    description: p:
    let
      lines = p |> builtins.readFile |> lib.strings.splitString "\n";
      # TODO: get description from definition
      head =
        lines
        |> builtins.filter (x: x |> lib.strings.hasPrefix "function")
        |> builtins.head
        |> builtins.match "--description \"(.+)\"";
      body =
        lines |> builtins.filter (x: x |> lib.strings.hasPrefix "  ") |> builtins.concatStringsSep "\n";
    in
    {
      inherit description;
      body = body;
    }
  );
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      emoji = "fzf-emoji";
      today = "date '+%Y-%m-%d'";
      tomorrow = "date '+%Y-%m-%d' --date '+1 day'";
    };
    interactiveShellInit = ''
      set --export --unpath SHELL fish
      test -e ${config.my.dotfilesDir}/config/fish/config.local.fish && source ${config.my.dotfilesDir}/config/fish/config.local.fish
    '';
    plugins = plugins;
    functions = {
      # keep-sorted start
      __lazygit = ./functions/__lazygit.fish |> parse-fish-function "Lazygit wrapper";
      as = ./functions/as.fish |> (parse-fish-function "fuzzy attach to an abduco session");
      f = ./functions/f.fish |> (parse-fish-function "fuzzy moving with ghq");
      fish_user_key_bindings =
        ./functions/fish_user_key_bindings.fish |> parse-fish-function "Key bindings";
      fzf-select = ./functions/fzf-select.fish |> parse-fish-function "Select file with fzf";
      fzf_history = ./functions/fzf_history.fish |> parse-fish-function "History with fzf";
      gi = ./functions/gi.fish |> parse-fish-function "git ignore provider";
      mkcd = ./functions/mkcd.fish |> parse-fish-function "mkdir -p && cd";
      t = ./functions/t.fish |> (parse-fish-function "fuzzy wotktree moving with ghq");
      # keep-sorted end
    };
  };
  # FIXME: "plugins" seems not create `themes`
  xdg.configFile = {
    "fish/themes/Catppuccin Mocha.theme".source = "${
      pkgs.dotfiles-sources |> builtins.getAttr "fish-catputtin" |> builtins.getAttr "src"
    }/themes/Catppuccin Mocha.theme";
  };
}
