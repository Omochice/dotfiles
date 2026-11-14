{
  ast-grep,
  formats,
  symlinkJoin,
  tree-sitter-moonbit,
  writeShellApplication,
}:
let
  sgconfig = (formats.yaml { }).generate "sgconfig.yml" {
    customLanguages.moonbit = {
      libraryPath = "${tree-sitter-moonbit}/parser";
      extensions = [ "mbt" ];
      # `_` would collide with ordinary identifiers such as `_unused`.
      expandoChar = "µ";
    };
  };
  wrapper = writeShellApplication {
    name = "ast-grep";
    text = ''
      real=${ast-grep}/bin/ast-grep

      # ast-grep has no user-level config, so a project config found by its own upward search must win.
      has_project_config() {
        local dir=$PWD
        while :; do
          if [[ -e $dir/sgconfig.yml || -e $dir/sgconfig.yaml ]]; then
            return 0
          fi
          if [[ $dir == / ]]; then
            return 1
          fi
          dir=$(dirname "$dir")
        done
      }

      case ''${1-} in
        run | scan | test | lsp)
          subcommand=$1
          shift
          ;;
        "" | -h | --help | -V | --version)
          exec "$real" "$@"
          ;;
        # A top-level option may come before the subcommand, and an explicit config or policy leaves nothing for the wrapper to add.
        -c | -c?* | --config | --config=* | --custom-languages | --custom-languages=*)
          exec "$real" "$@"
          ;;
        -*)
          subcommand=run
          ;;
        *)
          exec "$real" "$@"
          ;;
      esac

      for arg in "$@"; do
        case $arg in
          -c | -c?* | --config | --config=* | --custom-languages | --custom-languages=*)
            exec "$real" "$subcommand" "$@"
            ;;
        esac
      done

      if has_project_config; then
        exec "$real" "$subcommand" "$@"
      fi

      # The config lives in the store and is generated here, so loading its native library is trusted by construction.
      exec "$real" "$subcommand" --config ${sgconfig} --custom-languages allow "$@"
    '';
  };
in
symlinkJoin {
  name = "ast-grep-omochice";
  # The wrapper comes first so that its bin/ast-grep shadows the real one while completions are kept.
  paths = [
    wrapper
    ast-grep
  ];
  meta.mainProgram = "ast-grep";
}
