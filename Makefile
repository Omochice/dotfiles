all: ~/.deno install-brew

~/.deno:
	curl -fsSL https://deno.land/x/install/install.sh | bash

.PHONY: install-brew
install-brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

