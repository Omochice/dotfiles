export STARSHIP_CONFIG=$HOME/.config/starship/config.toml
export EDITOR=$(which vim)
export TERMINAL=$(which alacritty)
export BROWSER=$(which vivaldi-stable)

# golang
if [[ -e $HOME/.go ]]; then
    export GOROOT=$HOME/.go
    export GOPATH=$HOME/.go
    export PATH=$PATH:$GOPATH/bin
fi

# rust
if [[ -e $HOME/.cargo ]]; then
    source $HOME/.cargo/env
fi

# deno
if [[ -e $HOME/.deno ]]; then
    export PATH=$PATH:$HOME/.deno/bin
fi

# anyenv
if [[ -e $HOME/.anyenv ]]; then
    export PATH=$PATH:$HOME/.anyenv/bin
fi

# yarn
if [[ -e $HOME/.yarn ]]; then
    export PATH=$PATH:$HOME/.yarn/bin
fi

# source local settings
if [[ -e $HOME/.profile_local ]]; then
    source $HOME/.profile_local
fi
