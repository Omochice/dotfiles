# AI agent working directory

## .momomo/ai/ directory

`.momomo/ai/` is globally gitignored.

AI agent SHOULD use this directory for intermediate files such as:

- planning notes
- file comparison drafts
- screenshots and debug output
- any other temporary artifacts that are not final deliverables

Final deliverables (source code, notebooks, configs) SHOULD be placed in the
appropriate project location, not in `.momomo/ai/`.

Do NOT ask whether `.momomo/ai/` is gitignored - it always is.
