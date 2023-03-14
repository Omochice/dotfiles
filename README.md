# ☕ Dotfiles ☕

![desktop](https://i.gyazo.com/0394833c346a4f3430bc5d868d262974.png)
![desktop-on-mac](https://i.gyazo.com/bcd3f2fe56835a93aab36d4180a42eb7.jpg)

## Environment

I'm using several OSs :( (because of my work...)

- Linux (my favorite environment)
    - OS: [Manjaro](https://manjaro.org/)
    - WM: i3-gaps
- Mac (Umm... I'm not good at bsd-line os...)
    - OS: Mac(M1)
    - WM: [yabai](https://github.com/koekeishiya/yabai)
    - hotkeys: [skhd](https://github.com/koekeishiya/skhd), [karabiner-element](https://github.com/pqrs-org/Karabiner-Elements)
- Windows (Wht? Why?)
    - OS: Windows10
    - WM: [komorebi](https://github.com/LGUG2Z/komorebi)
    - hotkeys: [autohotkey](https://github.com/LGUG2Z/komorebi)

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

- Shell: [fish shell](https://fishshell.com/)(using with `chsh fish`)
- Prompt: [Starship](https://starship.rs/)

## Misc

- Font:
  - [yuru7/Firge](https://github.com/yuru7/Firge)
  - Noto font

## Dependency

- `Deno`
- `Git`

## Usage(outdated!)

1. sync dotfiles
   ```bash
   $ deno run --allow-env --allow-read --allow-write scripts/sync.ts
   ```
2. sync tools
   ```bash
   $ deno run --allow-env --allow-net --allow-read --allow-run scripts/syncer.ts ./tool-list.toml
   ```

if exist original dotfiles, move their into `/tmp/??/` (auto-make by `Deno.makeTempDirSync`)
