# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {||
  let c = if ($env.LAST_EXIT_CODE == 1) {
    (ansi red)
  } else {
    (ansi reset)
  }
  $"($c)$ (ansi reset)"
}
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    # FIXME: This default is not implemented in rust code as of 2023-09-06.
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

def create_left_prompt [] {
    let firstline_pre = $"(ansi default)╭───────────────────→(ansi reset)"
    let git_info = if ($"($env.PWD)/.git" | path exists) {
      let branch = $"🌱 (ansi green)(git rev-parse --abbrev-ref HEAD)(ansi reset)"
      let _stash = (git stash list | wc -l | str trim)
      let stash = if $_stash == "0" {
        ""
      } else {
        $"(ansi green)St:($_stash)(ansi reset)"
      }

      let _modify = (git status -s | grep "^\\sM" | wc -l | str trim)
      let modify = if $_modify == "0" {
        ""
      } else {
        $"(ansi green)M:($_modify)(ansi reset)"
      }

      let _staged = (git status -s | grep "^M" | wc -l | str trim)
      let staged = if $_staged == "0" {
        ""
      } else {
        $"(ansi green)S:($_staged)(ansi reset)"
      }

      [$firstline_pre $branch "[" $stash $modify $staged "]"]
        | filter { |x| $x != "" }
        | str join " "

    } else {
      $firstline_pre
    }
    let path_segment = $"├ (ansi yellow)(whoami)(ansi reset) in (ansi green)($env.PWD)(ansi reset)"
    let prompt = $"╰─→ "

    [$git_info $path_segment $prompt] | str join (char newline)
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%m-%d %H:%M')
    ] | str join)

    $time_segment
}

$env.PROMPT_COMMAND = { create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { create_right_prompt }
