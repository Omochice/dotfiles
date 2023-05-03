BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: link install-brew nvim

~/.deno:
	bash -c "$$(curl -fsSL https://deno.land/x/install/install.sh)"

.PHONY: install-brew
install-brew:
	command -v brew &>/dev/null || bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

install: install-brew
	command -v pacman &>/dev/null && sudo pacman -S i3-wm polybar picom rofi base-devel wezterm vivaldi || true
	# M1
	[ -e /opt/homebrew/bin/brew ] && /opt/homebrew/bin/brew bundle --file=$(BASE_DIR)/Brewfile || true
	# linux
	[ -e /home/linuxbrew/.linuxbrew/bin/brew ] && /home/linuxbrew/.linuxbrew/bin/brew bundle --file=$(BASE_DIR)/Brewfile || true

link: ~/.deno
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/linker.ts

.PHONY: nvim
nvim:
	[ -d ~/Tools ] || mkdir -p ~/Tools
	[ -d ~/Tools/neovim ] || git clone --depth 10 https://github.com/neovim/neovim.git ~/Tools/neovim
	cd ~/Tools/neovim && git pull && $(BASE_DIR)/scripts/install-nvim.sh



fish: install ~/.deno link
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/path-generator.ts $(BASE_DIR)/path-list* --shell fish > ~/.config/fish/config.fish


.PHONY: chsh
chsh: fish
	sudo chsh -s $(shell brew --prefix)/bin/fish


.PHONY: font
font: install
	wget https://github.com/yuru7/Firge/releases/download/v0.2.0/FirgeNerd_v0.2.0.zip --directory-prefix /tmp
	unzip /tmp/FirgeNerd_v0.2.0.zip -d /tmp
	mkdir -p ~/.local/share/font/ttf ~/.local/share/font/otf
	mv /tmp/FirgeNerd_v0.2.0/*.ttf ~/.local/share/font/ttf
	fc-cache --force --verbose
