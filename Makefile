BASE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: link install-brew nvim chsh font

~/.deno:
	bash -c "$$(curl -fsSL https://deno.land/x/install/install.sh)"

.PHONY: install-brew
install-brew: ~/.deno
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/install-brew.ts

install: install-brew
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/install-commands.ts

link: ~/.deno
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/link-files.ts

.PHONY: ~/.deno
nvim:
	~/.deno/bin/deno run -A $(BASE_DIR)/scripts/tasks/install-nvim.ts

fish: install ~/.deno link
	~/.deno/bin/deno run -A https://raw.githubusercontent.com/Omochice/deno-shellrc-generator/main/src/cli.ts $(BASE_DIR)/path-list* --shell fish > $(BASE_DIR)/config/fish/config.fish

.PHONY: chsh
chsh: fish
	~/.deno/bin/deno run -A scripts/tasks/show-fishpath.ts | sudo tee --append /etc/shells
	~/.deno/bin/deno run -A scripts/tasks/chsh-to-fish.ts

.PHONY: font
font: ~/.deno
	~/.deno/bin/deno run -A scripts/tasks/install-font.ts
