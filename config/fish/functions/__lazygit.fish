function __lazygit
    set -l cmd (commandline)
    if test -z "$cmd"
        lazygit
    end
end
