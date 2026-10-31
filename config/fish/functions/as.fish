function as --description="fuzzy attach to a zmx session"
    if not type zmx >/dev/null 2>&1
        command echo "need zmx"
        return 1
    end
    if not type fzf >/dev/null 2>&1
        command echo "need fzf"
        return 1
    end

    set --local names (zmx list --short 2>/dev/null | string match -vr '^\s*$')
    if test -z "$names"
        command echo "no zmx session"
        return 1
    end

    set --local picked (printf '%s\n' $names | fzf --no-mouse --no-sort --height=30%)
    if test -z "$picked"
        return 1
    end

    zmx attach $picked
end
