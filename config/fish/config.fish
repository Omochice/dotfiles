# Fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showuntrackedfiles 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
set __fish_git_prompt_color_upstream_ahead green
set __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_untrackedfiles '☡'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_upstream_ahead '+'
set __fish_git_prompt_char_upstream_behind '-'


function fish_user_key_bindings
    bind \cr "peco_select_history (commandline -b)"
    # bind \ce "peco_recentd"
end

# aliases 
alias shutdown "sudo shutdown -h now"

alias pbcopy "xsel --clipboard --input"
alias pbpaste "xsel --clipboard --output"

alias tmux "tmux -u2"

if type "bat" >/dev/null 2>&1
    alias cat "bat"
else if type "batcat" >/dev/null 2>&1
    alias cat "batcat"
end

if type "exa" >/dev/null 2>&1
    alias ls "exa -g --time-style=long-iso"
end

alias diff "git diff"

# tmuxの自動起動
set count (ps aux | grep tmux | grep -v grep | wc -l)
if test $count -eq 0
    command tmux
else if test $count -eq 1
    command tmux a
end