function asdf_fzf
    if ! type "asdf" >/dev/null 2>&1
        echo "asdf is not executable"
        false # return err
    end
    if ! type "fzf" >/dev/null 2>&1
        echo "asdf is not executable"
        false # return err
    end
    set -l lang $argv[1]
    if test -z $lang
        # if not specity, select using fzf
        set lang (asdf plugin-list | fzf)
    end

    if test -n $lang
        set -l versions (asdf list-all $lang | fzf --tac --no-sort --multi)
        if test -n "$versions"
            for v in $versions
                echo asdf $lang $v
            end
        else
            false
        end
    end
end
