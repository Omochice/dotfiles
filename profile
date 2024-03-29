export STARSHIP_CONFIG=$HOME/.config/starship/config.toml
export TERMINAL=$(which wezterm)
export BROWSER=$(which vivaldi-stable)
export DOTDIR=$HOME/dotfiles
export XDG_CONFIG_HOME=$HOME/.config

if [ -d $HOME/.local/bin ]; then
    export PATH=$HOME/.local/bin:$PATH
fi

# EDITOR
# priority: nvim > vim > vi
if [ -x "$(command -v nvim)" ]; then
    export EDITOR=$(which nvim)
elif [ -x "$(command -v vim)" ]; then
    export EDITOR=$(which vim)
else
    export EDITOR=$(which vi)
fi

# golang
if [[ -d /usr/local/go ]]; then
    export PATH=$PATH:/usr/local/go/bin
fi
if [ -x "$(command -v go)" ]; then
    if [[ -e $HOME/.go ]]; then
        export GOPATH=$HOME/.go
    elif [[ -e $HOME/go ]]; then
        export GOPATH=$HOME/go
    else
        break
    fi
    export PATH=$PATH:$GOPATH/bin
    if [ ! -e $GOPATH ]; then
        mkdir -p $GOPATH/bin
  fi
fi

# rust
if [[ -e $HOME/.cargo ]]; then
    source $HOME/.cargo/env
fi

# deno
if [[ -e $HOME/.deno ]]; then
    export PATH=$PATH:$HOME/.deno/bin
fi

# asdf
if [[ -e /opt/asdf-vm ]]; then
    source /opt/asdf-vm/asdf.sh
fi

# # anyenv
# if [[ -e $HOME/.anyenv ]]; then
#     export PATH=$PATH:$HOME/.anyenv/bin
# fi

# yarn
if [[ -e $HOME/.yarn ]]; then
    export PATH=$PATH:$HOME/.yarn/bin
fi

# source local settings
if [[ -e $HOME/.profile_local ]]; then
    source $HOME/.profile_local
fi

# GR (cross-platform visualization appilcation framework)
if [[ -e $HOME/Tools/gr ]]; then
    export GRDIR=$HOME/Tools/gr
fi

# on macOS
if [[ $(uname) = Darwin ]]; then
    export HOMEBREW_NO_ENV_HINTS=TRUE
    export PATH=$PATH:/opt/homebrew/bin
    source $DOTDIR/scripts/mac-gnu-aliases.sh
fi

if [[ -e $HOME/.asdf ]]; then
    export PATH=$PATH:$HOME/.asdf/bin
fi

source $HOME/.bashrc
