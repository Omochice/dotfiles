function fish_user_key_bindings
  bind \cr "peco_select_history (commandline -b)"
end

# aliases 
alias shutdown "sudo shutdown -h now"
alias myupdate "sudo apt update && sudo apt autoremove -y && sudo apt upgrade -y"

alias pbcopy "xsel --clipboard --input"
alias pbpaste "xsel --clipboard --output"

alias tmux "tmux -u2"

if type "bat" > /dev/null 2>&1
    alias cat "bat"
else if type "batcat" > /dev/null 2>&1
    alias cat "batcat"
end 

if type "exa" > /dev/null 2>&1
    alias ls "exa -g --time-style=long-iso"
end 

alias diff "git diff"