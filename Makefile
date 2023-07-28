BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: link install-brew nvim chsh font

~/.deno:
	command -v deno 2>&1 && deno upgrade || bash -c "$$(curl -fsSL https://deno.land/x/install/install.sh)"

.PHONY: install-brew
install-brew: ~/.deno
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/install-brew.ts

install: install-brew
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/install-commands.ts

link: ~/.deno
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/link-files.ts

.PHONY: ~/.deno
nvim:
	~/.deno/bin/deno run --allow-env --allow-write --allow-read --allow-run https://pax.deno.dev/Omochice/deno-nvim-install-wrapper/cli.ts --pull-to ~/tools/nvim --install-to ~/.local/nvim

fish: install ~/.deno link
	~/.deno/bin/deno run -A https://pax.deno.dev/Omochice/dneo-shellrc-generator/cli.ts $(BASE_DIR)/path-list* --shell fish > $(BASE_DIR)/config/fish/config.fish

.PHONY: chsh
chsh: fish
	~/.deno/bin/deno run -A scripts/tasks/show-fishpath.ts | sudo tee --append /etc/shells
	~/.deno/bin/deno run -A scripts/tasks/chsh-to-fish.ts

.PHONY: font
font: ~/.deno
	~/.deno/bin/deno run -A scripts/tasks/install-font.ts
