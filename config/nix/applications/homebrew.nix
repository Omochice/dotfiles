{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
    };
    taps = [
      "felixkratz/formulae"
      "koekeishiya/formulae"
      "aquaproj/aqua"
    ];
    brews = [
      "aquaproj/aqua/aqua"
      "btop"
      "cmake"
      "curl"
      "fish"
      "gettext"
      "libtool"
      "mise"
      "ninja"
      "pkg-config"
      "starship"
      "tldr"
      "pnpm"
      "make"
      "nushell"
      "pandoc"
      "koekeishiya/formulae/yabai"
      "felixkratz/formulae/sketchybar"
    ];
    casks = [
      "alt-tab"
      "android-studio"
      "aquaskk"
      "discord"
      "gyazo"
      "karabiner-elements"
      "scroll-reverser"
      "slack"
      "vivaldi"
      "wezterm"
    ];
  };
}
