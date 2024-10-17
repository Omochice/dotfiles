$env.config = {
  show_banner: false
  keybindings: [
    {
      modifier: control
      keycode: char_o
      mode: [emacs, vi_normal, vi_insert]
      event: null
    },
    {
      name: open_editor
      modifier: alt
      keycode: char_e
      mode: [emacs, vi_normal, vi_insert]
      event: { send: OpenEditor }
    },
    {
      name: lazygit
      modifier: control
      keycode: char_g
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand, cmd: "lazygit" }
    },
    {
      name: file_search
      modifier: control
      keycode: char_q
      mode: [emacs, vi_normal, vi_insert]
      event: {
        send: ExecuteHostCommand,
        cmd: "commandline edit (
          fd --exclude '.git' --type file
            | fzf --no-sort --preview='bat {}' --height=30%
            | complete
            | $in.stdout
            | str trim
          )"
      }
    }
  ]
}

def --env f [] {
  let selected = (ghq list | fzf | complete | $in.stdout | str trim)
  match $selected {
    "" => {}
    _ => {
      cd (ghq root | str trim | path join $selected)
    }
  }
}

def today [] { date now | format date '%Y-%m-%d' }
def tomorow [] { date now | $in + 1day | format date '%Y-%m-%d' }
