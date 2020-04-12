alias shutdown='sudo shutdown -h now'
alias myupdate='sudo apt update && sudo apt autoremove -y && sudo apt upgrade -y'

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

alias tmux="tmux -u2"

if type "bat" > /dev/null 2>&1; then
    alias cat='bat'
elif type "batcat" > /dev/null 2>&1; then
    alias cat='batcat'
fi

if type "exa" > /dev/null 2>&1; then
    alias ls='exa -g --time-style=long-iso'
fi
alias ll='ls -l'
alias la='ls -al'
alias diff="git diff"