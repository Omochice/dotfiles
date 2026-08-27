$env.config = {
  show_banner: false
  hooks: {
    env_change: {
      PWD: [
        {|_before, _after|
          if ($env.NO_AUTO_LS? | is-empty) {
            print ""
            if (which lsd | is-not-empty) { ^lsd } else { print (ls) }
          }
        }
      ]
    }
  }
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
      event: {
        send: ExecuteHostCommand,
        cmd: "if (commandline | str trim | is-empty) and (^git branch --show-current | complete | get exit_code) == 0 { lazygit }"
      }
    },
    {
      name: file_search
      modifier: control
      keycode: char_q
      mode: [emacs, vi_normal, vi_insert]
      event: {
        send: ExecuteHostCommand,
        cmd: "commandline edit --insert (
          fd --exclude '.git' --exclude '.wt' --type file --hidden
            | fzf --no-mouse --no-sort --multi --preview='bat {}' --height=30%
            | complete
            | $in.stdout
            | lines
            | str join ' '
          )"
      }
    },
    {
      name: fzf_history
      modifier: control
      keycode: char_r
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand, cmd: "fzf-history" }
    },
    {
      name: fzf_emoji
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ExecuteHostCommand, cmd: "fzf-emoji" }
    },
    {
      name: emptyls
      modifier: none
      keycode: enter
      mode: [emacs, vi_normal, vi_insert]
      event: [
        { send: ExecuteHostCommand, cmd: "if (commandline | str trim | is-empty) { ls }" },
        { send: Enter }
      ]
    }
  ]
}

def --env f [query: string = ""] {
  let roots = (ghq root --all | lines)
  # fzf runs previews with `$SHELL -c`, which is nushell here, so the preview is nu syntax.
  let preview = ($roots | each {|root| $"if \('($root)' | path join {} README.md | path exists\) { bat --color=always --plain \('($root)' | path join {} README.md\) } else" } | append "{ echo 'NO README' }" | str join " ")
  let repo = (ghq list | lines | where $it !~ '-wt/' | str join "\n" | fzf --no-mouse --preview $preview --query $query | str trim)
  if ($repo | is-empty) { return }
  for root in $roots {
    let p = ($root | path join $repo)
    if ($p | path exists) {
      cd $p
      return
    }
  }
}

def --env t [] {
  let repo = (^git remote get-url origin | complete | get stdout | str trim)
  if ($repo | is-empty) { return }
  let parent = $"((ghq root | str trim))/($repo | str replace -r '^(https?|ssh)://' '' | path dirname)/"
  let lines = (^git wt | lines | str replace $parent "" | skip 1)
  let picked = ($lines | str join "\n" | fzf --no-mouse --preview "git log --graph --oneline --color {-1}" | str trim)
  if ($picked | is-empty) { return }
  let fields = ($picked | split row -r '\s+')
  # git-wt prints the worktree path as its last line; the shell integration
  # fish relies on for cd does not exist for nushell.
  cd (git-wt ($fields | reverse | get 1) | lines | last)
}

def as [] {
  let rows = (abduco | complete | get stdout | lines | skip 1 | where ($it | str trim | is-not-empty))
  if ($rows | is-empty) {
    print "no abduco session"
    return
  }
  let picked = ($rows | str join "\n" | fzf --no-mouse --no-sort --height=30% | str trim)
  if ($picked | is-empty) { return }
  abduco -a ($picked | split row "\t" | last)
}

def gi [] {
  let selected = (
    gh api gitignore/templates
    | from json
    | str join "\n"
    | fzf --no-mouse --no-sort --multi --preview="gh api gitignore/templates/{} | jq -r '.source'" --height=50% --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up'
    | lines
  )
  for lang in $selected {
    gh api $"gitignore/templates/($lang)" | from json | get source
  }
}

def --env mkcd [p: path] {
  print $"mkdir -p ($p) && cd ($p)"
  mkdir $p
  cd $p
}

def fzf-history [] {
  let result = (
    history
    | get command
    | reverse
    | uniq
    | str join (char nul)
    | fzf --read0 --no-mouse --height=40% --tiebreak=index --query (commandline)
    | complete
  )
  if $result.exit_code == 0 {
    commandline edit --replace ($result.stdout | str trim)
  }
}

def fzf-emoji [] {
  # The dictionary is shared with fzf-emoji.fish, so both shells download it once.
  let destination = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config") | path join "fzf-emoji")
  let dictionary = ($destination | path join "emoji.json")
  if not ($dictionary | path exists) {
    mkdir $destination
    http get --raw "https://raw.githubusercontent.com/b4b4r07/emoji-cli/master/dict/emoji.json" | save $dictionary
  }
  let selected = (
    open $dictionary
    | each {|e| $e.tags | each {|tag| $e.aliases | each {|alias| $"($tag): ($e.emoji) :($alias):" } } | flatten }
    | flatten
    | str join "\n"
    | fzf --height=10 --with-nth=..-2
    | str trim
  )
  if ($selected | is-empty) { return }
  let code = ($selected | parse -r '(:\w+:)' | get capture0.0)
  if (which pbcopy | is-not-empty) {
    $code | pbcopy
  } else if (which xsel | is-not-empty) {
    $code | xsel --clipboard --input
  } else {
    print -e "Error `xsel` or `pbcopy` is needed."
  }
}

def today [] { date now | format date '%Y-%m-%d' }
def tomorrow [] { date now | $in + 1day | format date '%Y-%m-%d' }

alias emoji = fzf-emoji
