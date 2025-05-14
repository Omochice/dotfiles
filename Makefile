BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: mac enable-service install-deno enable-catppuccin-theme

mac: enable-service macskk deno

enable-service: nix-environment
	/opt/homebrew/bin/brew services start sketchybar
	/opt/homebrew/bin/yabai --start-service

macskk:
	cp $(BASE_DIR)/config/macskk/kana-rule.conf ~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Settings/

deno:
	curl -fsSL https://deno.land/install.sh | sh

enable-catppuccin-theme:
	fish -c 'fish_config theme save "Catppuccin Mocha"'

~/.config/nix/nix.conf:
	mkdir -p ~/.config/nix
	ln -snf $(BASE_DIR)/config/nix/nix.conf ~/.config/nix/nix.conf

nix-environment: nix-darwin

home-manager: ~/.config/nix/nix.conf
	nix run github:nix-community/home-manager -- switch --flake .#omochice --impure

nix-darwin: home-manager
	sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
	sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
	nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice --impure
