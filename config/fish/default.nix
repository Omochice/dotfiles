{ lib, pkgs, ... }:
let
  # FIXME: wsl
  os = if pkgs.stdenv.isDarwin then "darwin" else "linux";
  matchOS = (x: !(x ? "os") || x.os == os);
  matchShell = (x: !(x ? "shell") || x.shell == "fish");
  isFishConfig = (x: (matchOS x) && (matchShell x));
  opt = (
    x:
    (lib.strings.optionalString (x ? "if_exists") "test -e ${x.if_exists} && ")
    + (lib.strings.optionalString (
      x ? "if_executable"
    ) "command -v ${x.if_executable} >/dev/null 2>&1 && ")
  );
  source-to-eval = (x: (opt x) + "source ${x.path}");
  environment-to-eval = (x: (opt x) + "set --export --unpath ${x.to} ${x.from}");
  path-to-eval = (x: (opt x) + "set --path PATH $PATH ${x.path}");
  eval-to-eval = (x: (opt x) + x.command);

  config = ../../path-list.toml |> builtins.readFile |> builtins.fromTOML;
  plugins =
    pkgs.callPackage ../../_sources/generated.nix { }
    |> lib.attrsets.filterAttrs (k: v: k |> lib.strings.hasPrefix "fish-")
    |> builtins.attrValues
    |> builtins.filter (x: (builtins.typeOf x) == "set" && x ? "pname")
    |> builtins.map (x: {
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

  executes = config.executes |> builtins.filter isFishConfig |> builtins.map eval-to-eval;
  paths = config.paths |> builtins.filter isFishConfig |> builtins.map path-to-eval;
  environments =
    config.environments |> builtins.filter isFishConfig |> builtins.map environment-to-eval;
  sources = config.sources |> builtins.filter isFishConfig |> builtins.map source-to-eval;
  post = [
    "test -e ~/dotfiles/config/fish/config.local.fish && source ~/dotfiles/config/fish/config.local.fish"
  ];
  interactiveShellInit =
    (executes ++ paths ++ environments ++ sources ++ post) |> lib.strings.concatStringsSep "\n";
in
{
  programs.fish = {
    enable = true;
    shellAliases =
      config.aliases
      |> builtins.filter isFishConfig
      |> builtins.map (x: {
        name = x.to;
        value = x.from;
      })
      |> builtins.listToAttrs;
    interactiveShellInit = interactiveShellInit;
    plugins = plugins;
    functions = {
      # keep-sorted start
      __lazygit = ./functions/__lazygit.fish |> parse-fish-function "Lazygit wrapper";
      f = ./functions/f.fish |> (parse-fish-function "fuzzy moving with ghq");
      fish_user_key_bindings =
        ./functions/fish_user_key_bindings.fish |> parse-fish-function "Key bindings";
      fzf-select = ./functions/fzf-select.fish |> parse-fish-function "Select file with fzf";
      fzf_history = ./functions/fzf_history.fish |> parse-fish-function "History with fzf";
      gi = ./functions/gi.fish |> parse-fish-function "git ignore provider";
      mkcd = ./functions/mkcd.fish |> parse-fish-function "mkdir -p && cd";
      # keep-sorted end
    };
  };
  # FIXME: "plugins" seems not create `themes`
  xdg.configFile = {
    "fish/themes/Catppuccin Mocha.theme".source = "${
      pkgs.callPackage ../../_sources/generated.nix { }
      |> builtins.getAttr "fish-catputtin"
      |> builtins.getAttr "src"
    }/themes/Catppuccin Mocha.theme";
  };
}
