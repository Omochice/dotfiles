function fkill
    set --local pid
    set --local query
    # if specity arg, use it as initialize query
    if test -n $argv[1]
        set query "--query=$argv[1]"
    else
        set query ""
    end

    if test "$UID" != "0"
        set pids (ps -f -u $UID | sed 1d | fzf --multi $query | awk '{print $2}')
    else
        set pids (ps -ef  | sed 1d | fzf --multi $query | awk '{print $2}')
    end

    if test -n "$pids"
        for pid in $pids
            command kill $pid
        end
        true
        return
    end
    false
end
