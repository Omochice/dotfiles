BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: mac enable-service install-deno enable-catppuccin-theme

mac: /nix

enable-service:
	brew services start sketchybar

macskk:
	cp $(BASE_DIR)/config/macskk/kana-rule.conf ~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Settings/

install-deno:
	curl -fsSL https://deno.land/install.sh | sh

enable-catppuccin-theme:
	fish -c 'fish_config theme save "Catppuccin Mocha"'

/nix:
	sh <(curl -L https://nixos.org/nix/install)
