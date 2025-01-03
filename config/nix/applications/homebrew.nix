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
      "cmake"
      "gettext"
      "libtool"
      "ninja"
      "pkg-config"
      "koekeishiya/formulae/yabai"
      "felixkratz/formulae/sketchybar"
    ];
    casks = [
      "alt-tab"
      "android-studio"
      "mtgto/macskk/macskk"
      "discord"
      "gyazo"
      "karabiner-elements"
      "scroll-reverser"
      "slack"
      "vivaldi"
      "google-chrome@canary"
      "wezterm@nightly"
      "utm"
      "crystalfetch"
    ];
  };
}
