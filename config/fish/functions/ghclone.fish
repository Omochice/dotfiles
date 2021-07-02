function ghclone
  gh repo clone (gh repo list $argv[1] --json nameWithOwner -q '.[].nameWithOwner' | fzf)
end
