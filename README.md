# ☕ Dotfiles ☕

![desktop](https://i.gyazo.com/0394833c346a4f3430bc5d868d262974.png)

## Environment

- OS: [Manjaro](https://manjaro.org/)
- WM: i3-gaps

## Apps

- Bar: [bumblebee-status](https://github.com/tobi-wan-kenobi/bumblebee-status)
- Editor: Vim, Neovim
- Terminal: [Wezterm](https://github.com/wez/wezterm)
- Screenshot:
  - [Gyazo-for-Linux](https://github.com/gyazo/Gyazo-for-Linux)
  - [Gyago-cli](https://github.com/Omochice/gyazo-cli) forked from
    [here](https://github.com/tomohiro/gyazo-cli)
- Screen Recorder
  - [giph](https://github.com/phisch/giph)
- Launcher: rofi
  - [rofimoji](https://github.com/fdw/rofimoji)

## CLI

- Shell: [fish shell](https://fishshell.com/)(via bash)
- Prompt: [Starship](https://starship.rs/)

## Misc

- Font:
  - [yuru7/Firge](https://github.com/yuru7/Firge)
  <!-- - [nerd-fonts-fira-code](https://aur.archlinux.org/packages/nerd-fonts-fira-code/) -->
  - Noto font

## Dependency

- `Deno`
- `Git`

## Usage

1. sync dotfiles
   ```bash
   $ deno run --allow-env --allow-read --allow-write scripts/sync.ts
   ```
2. sync tools
   ```bash
   $ deno run --allow-env --allow-net --allow-read --allow-run scripts/syncer.ts ./tool-list.toml
   ```

if exist original dotfiles, move their into `/tmp/??/` (auto-make by `Deno.makeTempDirSync`)
