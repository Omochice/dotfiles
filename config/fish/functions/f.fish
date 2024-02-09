function f --description "fuzzy moving with ghq"
  if ! type "ghq" 2>&1 >/dev/null
    echo "ghq is not included into PATH"
    return (false)
  end
  if ! type "fzf" 2>&1 >/dev/null
    echo "fzf is not included into PATH"
    return (false)
  end
  set --local root (ghq root)

  set --local repo (ghq list | fzf --preview "cat '$root/{}/README.md' || echo 'NO README'" --query "$argv[1]")
  if test -z "$repo"
    return (false)
  end
  cd "$root"/"$repo"
end
