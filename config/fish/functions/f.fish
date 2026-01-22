function f --description="fuzzy moving with ghq"
    if ! type ghq 2>&1 >/dev/null
        echo "ghq is not included into PATH"
        return (false)
    end
    if ! type fzf 2>&1 >/dev/null
        echo "fzf is not included into PATH"
        return (false)
    end
    if ! type bat 2>&1 >/dev/null
        echo "bat is not included into PATH"
        return (false)
    end
    set --local roots (ghq root --all)
    set --local repo (ghq list | string match --invert "*-wt/*" | fzf --preview "
      for root in $roots
        if bat --color=always --plain \$root/{}/README.md 2>/dev/null
          exit
        end
      end
      echo 'NO README'" --query "$argv[1]")
    if test -z "$repo"
        return (false)
    end
    for root in $roots
        set --local p "$root"/"$repo"
        if test -d "$p"
            cd "$p"
            return (true)
        end
    end
    # unreachable because `ghq list` show only repos into `ghq root --all`
    return (false)
end
