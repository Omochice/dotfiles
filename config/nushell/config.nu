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
