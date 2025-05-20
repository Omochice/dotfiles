{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
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
      "colima"
      "felixkratz/formulae/sketchybar"
      "gettext"
      "git-svn"
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
      "google-chrome"
      "google-chrome@beta"
      "google-chrome@canary"
      "gyazo"
      "karabiner-elements"
      "mtgto/macskk/macskk"
      "obs"
      "scroll-reverser"
      "slack"
      "utm"
      "visual-studio-code"
      "vivaldi"
      "vysor"
      "wezterm@nightly"
      "windows-app"
      # keep-sorted end
    ];
  };
}
