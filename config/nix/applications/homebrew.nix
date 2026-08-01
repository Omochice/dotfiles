{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      {
        name = "arto-app/tap";
        trusted = true;
      }
      {
        name = "felixkratz/formulae";
        trusted = true;
      }
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
      "alacritty"
      "alt-tab"
      "android-studio"
      "crystalfetch"
      "discord"
      "google-chrome"
      "google-chrome@beta"
      "google-chrome@canary"
      "gyazo"
      "mtgto/macskk/macskk"
      "obs"
      "scroll-reverser"
      "shottr"
      "slack"
      "utm"
      "visual-studio-code"
      "vivaldi"
      "vysor"
      "windows-app"
      "wireshark-app"
      "xcodes-app"
      "zen"
      {
        name = "arto-app/tap/arto";
      }
      {
        name = "karabiner-elements";
        greedy = true;
      }
      {
        name = "tailscale-app";
        greedy = true;
      }
      {
        name = "wezterm@nightly";
        greedy = true;
      }
      {
        name = "zoom";
        greedy = true;
      }
      # keep-sorted end
    ];
  };
}
