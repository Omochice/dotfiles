BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: mac enable-service enable-catppuccin-theme

mac: enable-service macskk

enable-service: nix-environment
	/opt/homebrew/bin/brew services start sketchybar
	/opt/homebrew/bin/yabai --start-service

macskk:
	cp $(BASE_DIR)/config/macskk/kana-rule.conf ~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Settings/

enable-catppuccin-theme:
	fish -c 'fish_config theme save "Catppuccin Mocha"'

~/.config/nix/nix.conf:
	mkdir -p ~/.config/nix
	cp $(BASE_DIR)/config/nix/nix.conf ~/.config/nix/nix.conf

nix-environment: nix-darwin

host.json:
	echo '{"home": "${HOME}", "user": "${USER}"}' > host.json

home-manager: ~/.config/nix/nix.conf host.json
	nix run github:nix-community/home-manager -- switch --flake .#omochice

nix-darwin: home-manager host.json
	sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
	sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
	sudo nix run github:nix-darwin/nix-darwin -- switch --flake .#omochice
