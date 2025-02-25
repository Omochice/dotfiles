{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
    };
    taps = [
      # keep-sorted start
      "aquaproj/aqua"
      "felixkratz/formulae"
      "koekeishiya/formulae"
      # keep-sorted end
    ];
    brews = [
      # keep-sorted start
      "aquaproj/aqua/aqua"
      "cmake"
      "felixkratz/formulae/sketchybar"
      "gettext"
      "koekeishiya/formulae/yabai"
      "libtool"
      "ninja"
      "pkg-config"
      # keep-sorted end
    ];
    casks = [
      # keep-sorted start
      "alt-tab"
      "android-studio"
      "crystalfetch"
      "discord"
      "google-chrome@canary"
      "gyazo"
      "karabiner-elements"
      "mtgto/macskk/macskk"
      "scroll-reverser"
      "slack"
      "utm"
      "vivaldi"
      "wezterm@nightly"
      # keep-sorted end
    ];
  };
}
