## Fish git prompt
#set __fish_git_prompt_showdirtystate 'no'
#set __fish_git_prompt_showstashstate 'yes'
#set __fish_git_prompt_showuntrackedfiles 'yes'
#set __fish_git_prompt_showupstream 'yes'
#set __fish_git_prompt_color_branch yellow
#set __fish_git_prompt_color_upstream_ahead green
#set __fish_git_prompt_color_upstream_behind red

## Status Chars
#set __fish_git_prompt_char_dirtystate ''
#set __fish_git_prompt_char_stagedstate '+'
#set __fish_git_prompt_char_untrackedfiles '!'
#set __fish_git_prompt_char_stashstate '*'
#set __fish_git_prompt_char_upstream_ahead '+'
#set __fish_git_prompt_char_upstream_behind '-'

# Tesseract
if [ -d /usr/share/tessdata ]
    set TESSDATA_PREFIX /usr/share/tessdata
end

# set SHELL (which fish)


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
    alias ls "exa --icons -g --time-style=long-iso"
end

alias gs "git status"
alias diff "git diff"
alias ptpython "ptpython --vi"
alias ptipython "ptipython --vi"
alias today "date '+%Y-%m-%d'"
alias tomorrow "date '+%Y-%m-%d' --date '+1 day'"
alias view "vim -R"

if type "nvim" >/dev/null 2>&1
    alias v "nvim"
    alias vi "nvim"
    alias vim "nvim"
    alias vvim (which vim)
else
    alias v "vim"
    alias vi "vim"
end

if type "license-generator" >/dev/null 2>&1
    alias license "license-generator --author Omochice"
end

# paru override yay
if type "paru" >/dev/null 2>&1
    alias yay "paru"
end

# abbr commands
abbr f77 gfortran
abbr tree "ls -T"
abbr gst "git status"
abbr gsw "git switch"
abbr gcm "git commit -m"
abbr vimrc "vim ~/.vimrc"
abbr :q "exit"
abbr lz "lazygit"
abbr giph "giph -f 5 -s -l -c 0.3,0,0.4,0.5 -b 5 -p -5"
abbr rm "rip"
abbr germanium "germanium -f Firge35NerdConsole-Regular"

# tmuxの自動起動
set count (ps aux | grep tmux | grep -v grep | wc -l)
if test $count -eq 0
    command tmux
else if test $count -eq 1
    command tmux a
end

# asdf for fish
if type "asdf" >/dev/null 2>&1
    abbr pip "__pip"
end

# Github CLI
eval (gh completion -s fish | source)

# Starship
starship init fish | source
