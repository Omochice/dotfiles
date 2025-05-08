BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: mac enable-service install-deno enable-catppuccin-theme

mac: enable-service macskk deno

enable-service: nix-environment
	brew services start sketchybar
	yabai --start-service

macskk:
	cp $(BASE_DIR)/config/macskk/kana-rule.conf ~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Settings/

deno:
	curl -fsSL https://deno.land/install.sh | sh

enable-catppuccin-theme:
	fish -c 'fish_config theme save "Catppuccin Mocha"'

~/.config/nix/nix.conf:
	mkdir -p ~/.config/nix
	ln -snf $(BASE_DIR)/config/nix/nix.conf ~/.config/nix/nix.conf

nix-environment: ~/.config/nix/nix.conf
	nix run .#update
