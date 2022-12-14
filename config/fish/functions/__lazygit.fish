function __lazygit
    set -l cmd (commandline)
    if test -z "$cmd"
        lazygit
    end
    fish_default_mode_prompt
end
