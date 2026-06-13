function as --description="fuzzy attach to an abduco session"
    if not type abduco >/dev/null 2>&1
        command echo "need abduco"
        return 1
    end
    if not type fzf >/dev/null 2>&1
        command echo "need fzf"
        return 1
    end

    # abduco prints a header line followed by tab-separated session rows
    # whose last field is the session name; drop the header before picking.
    set --local rows (abduco 2>/dev/null | tail -n +2 | string match -vr '^\s*$')
    if test -z "$rows"
        command echo "no abduco session"
        return 1
    end

    set --local picked (printf '%s\n' $rows | fzf --no-sort --height=30%)
    if test -z "$picked"
        return 1
    end

    set --local name (string split \t -- $picked)[-1]
    abduco -a $name
end
