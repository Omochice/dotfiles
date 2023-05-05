BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: link install-brew nvim chsh font

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
font: ~/.deno
	~/.deno/bin/deno run -A scripts/tasks/install-font.ts
