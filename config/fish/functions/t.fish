function t --description="fuzzy wotktree moving with ghq"
    set --local repo (git remote get-url origin)
    if test -z "$repo"
        return (false)
    end
    set --local parent (ghq root)/(echo "$repo" | string replace -r "^(https?|ssh)://" "" | path dirname)/
    set --local lines (git wt | string replace "$parent" "" |  string split \n)
    set --local picked (printf '%s\n' $lines[2..] | fzf --preview "git log --graph --oneline --color {-1}")
    set --local fields (string split -n ' ' -- $picked)
    if test -z "$fields"
        return (false)
    end
    git wt $fields[-2]
end
