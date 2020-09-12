alias shutdown='sudo shutdown -h now'
alias tree='tree -C'

alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

alias tmux="tmux -u2"

alias ll="ls -al"
alias la="ls -a"

if type "bat" >/dev/null 2>&1; then
    alias cat="bat"
elif type "batcat" >/dev/null 2>&1; then
    alias cat="batcat"
fi

if type "exa" >/dev/null 2>&1; then
    alias ls="exa -g --time-style=long-iso"
fi
