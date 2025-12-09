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
      "felixkratz/formulae"
      # keep-sorted end
    ];
    brews = [
      # keep-sorted start
      "aqua"
      "cmake"
      "colima"
      "felixkratz/formulae/sketchybar"
      "gettext"
      "libtool"
      "ninja"
      "pkg-config"
      # keep-sorted end
    ];
    casks = [
      # keep-sorted start block=yes
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
      "shottr"
      "slack"
      "tailscale"
      "utm"
      "visual-studio-code"
      "vivaldi"
      "vysor"
      "wezterm@nightly"
      "windows-app"
      "xcodes"
      "zoom"
      {
        name = "lambdalisue/arto/arto";
        args.no_quarantine = true;
      }
      # keep-sorted end
    ];
  };
}
