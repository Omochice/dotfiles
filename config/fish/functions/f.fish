function f --description "fuzzy moving with ghq"
  if ! type "ghq" 2>&1 >/dev/null
    echo "ghq is not included into PATH"
    false
  end
  if ! type "fzf" 2>&1 >/dev/null
    echo "fzf is not included into PATH"
    false
  end
  set --local root (ghq root)

  set --local repo (ghq list | fzf --preview "cat '$root/{}/README.md' || echo 'NO README'")
  if test -z "$repo"
    false
  end
  cd $root/$repo
end
