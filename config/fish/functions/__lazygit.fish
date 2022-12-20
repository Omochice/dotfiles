function __lazygit
    set --local cmd (commandline)
    if test -z "$cmd"
        lazygit
    end
    fish_default_mode_prompt
    commandline --function repaint
end
