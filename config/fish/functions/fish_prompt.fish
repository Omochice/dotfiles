function fish_prompt
    echo
    set last_status $status
    if not set -q VIRTUAL_ENV_DISABLE_PROMPT
        set -g VIRTUAL_ENV_DISABLE_PROMPT true
    end
    set_color yellow
    printf '%s' $USER
    set_color normal
    printf ' at '

    set_color magenta
    echo -n (prompt_hostname)
    set_color normal
    printf ' in '

    set_color $fish_color_cwd
    printf '%s ' (prompt_pwd)
    set_color normal

    # Git 
    printf '%s ' (__fish_git_prompt)
    set_color normal

    # Line 2
    echo
    if test $VIRTUAL_ENV
        printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
    end

    if test $last_status -gt 0
        set_color red
    end

    printf '↪ '
    if test (id -u) -eq 0
        printf '# '
    else
        printf '$ '
    end

    set_color normal
end


function fish_right_prompt
    date +"[ %H:%M ]"
end
