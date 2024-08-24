{
  description = "Omochice dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
    }:
    let
      configuration =
        {
          pkgs,
          services,
          system,
          ...
        }:
        {
          imports = [ ./config/nix/modules/darwin/default.nix ];
          nix = {
            package = pkgs.nix;
            optimise.automatic = true;
            settings = {
              experimental-features = "nix-command flakes";
              max-jobs = 8;
            };
          };
          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          system = {
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 4;
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            defaults = {
              NSGlobalDomain = {
                "com.apple.sound.beep.volume" = 0.0;
                InitialKeyRepeat = 25;
                KeyRepeat = 2;
                _HIHideMenuBar = true;
                AppleActionOnDoubleClick = "None";
                AppleMiniaturizeOnDoubleClick = false;
                AppleMenuBarVisibleInFullscreen = false;
              };
              trackpad = {
                Clicking = true;
                TrackpadMomentumScroll = true;
              };
              trackpadBluetooth = {
                TrackpadMomentumScroll = true;
              };
              dock = {
                autohide = true;
                tilesize = 48;
                orientation = "left";
              };
              finder = {
                ShowPathbar = true;
                ShowStatusBar = true;
              };
              WindowManager = {
                HideDesktop = false;
                EnableStandardClickToShowDesktop = false;
              };
              CustomUserPreferences = {
                "com.apple.Spotlight" = {
                  orderedItems = [
                    {
                      enabled = false;
                      name = "PDF";
                    }
                    {
                      enabled = false;
                      name = "MENU_SPOTLIGHT_SUGGESTIONS";
                    }
                    {
                      enabled = false;
                      name = "BOOKMARKS";
                    }
                    {
                      enabled = true;
                      name = "APPLICATIONS";
                    }
                    {
                      enabled = false;
                      name = "EVENT_TODO";
                    }
                    {
                      enabled = false;
                      name = "SYSTEM_PREFS";
                    }
                    {
                      enabled = false;
                      name = "SPREADSHEETS";
                    }
                    {
                      enabled = false;
                      name = "MENU_OTHER";
                    }
                    {
                      enabled = false;
                      name = "TIPS";
                    }
                    {
                      enabled = false;
                      name = "DIRECTORIES";
                    }
                    {
                      enabled = false;
                      name = "FONTS";
                    }
                    {
                      enabled = false;
                      name = "PRESENTATIONS";
                    }
                    {
                      enabled = false;
                      name = "MUSIC";
                    }
                    {
                      enabled = false;
                      name = "MOVIES";
                    }
                    {
                      enabled = false;
                      name = "MESSAGES";
                    }
                    {
                      enabled = false;
                      name = "IMAGES";
                    }
                    {
                      enabled = false;
                      name = "MENU_EXPRESSION";
                    }
                    {
                      enabled = false;
                      name = "DOCUMENTS";
                    }
                    {
                      enabled = false;
                      name = "MENU_DEFINITION";
                    }
                    {
                      enabled = false;
                      name = "MENU_CONVERSION";
                    }
                    {
                      enabled = false;
                      name = "CONTACT";
                    }
                  ];
                };
              };
            };
          };
        };
    in
    {
      formatter = {
        aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
      };
      darwinConfigurations = {
        omochice = nix-darwin.lib.darwinSystem { modules = [ configuration ]; };
      };
    };
}
