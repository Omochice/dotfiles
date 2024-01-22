$env.shell_integration = ($env.OS? != "Windows_NT")

$env.config = {
  show_banner: false
  keybindings: [
    {
      name: lazygit
      modifier: control
      keycode: char_g
      mode: emacs
      event: { send: ExecuteHostCommand cmd: "lazygit" }
    }
    {
      name: fzf
      modifier: control
      keycode: char_q  # TODO: I want to disable new prompt...
      mode: emacs
      event: [
        {
          send: ExecuteHostCommand
          cmd: "commandline (
            fd --exclude '.git' --type file
              | fzf --no-sort --multi --preview='bat {}' --height=30%
              | decode utf-8
              | str trim
          )"
        }
      ]
    }
    {
      name: fuzzy_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: [
        {
          send: ExecuteHostCommand
          cmd: "commandline (
            history
              | each { |it| $it.command }
              | uniq
              | reverse
              | str join (char -i 0)
              | fzf --read0 --layout=reverse --height=40% -q (commandline)
              | decode utf-8
              | str trim
          )"
        }
      ]
    }
    {
      name: edit_by_nvim
      modifier: alt
      keycode: char_e
      mode: emacs
      event: [
        { send: openeditor }
      ]
    }
  ]
  completions: {
    algorithm: "fuzzy"
  }
}

def nuopen [arg, --raw (-r)] { if $raw { open -r $arg } else { open $arg } }
alias open = ^open
