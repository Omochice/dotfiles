{
  pkgs,
  user,
  home,
  ...
}:
let
  nodePkgs = pkgs.callPackage ../../node2nix/default.nix { inherit pkgs; };
in
{
  imports = [
    # keep-sorted start
    ../../aqua/default.nix
    ../../claude/default.nix
    ../../colima/default.nix
    ../../fish/default.nix
    ../../gh/default.nix
    ../../git/default.nix
    ../../glab-cli/default.nix
    ../../karabiner/default.nix
    ../../lazygit/default.nix
    ../../nix/default.nix
    ../../nushell/default.nix
    ../../nvim/default.nix
    ../../sketchybar/default.nix
    ../../starship/default.nix
    ../../wezterm/default.nix
    ../../yabai/default.nix
    ../../yazi/default.nix
    ../../zathura/default.nix
    ../../zoxide/default.nix
    # keep-sorted end
    # ../../macskk/default.nix
  ];
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  home = {
    username = user;
    homeDirectory = home;
    stateVersion = "24.05";
    packages = with pkgs; [
      # keep-sorted start
      awscli2
      btop
      cachix
      cargo
      ccusage
      clang-tools
      curl
      devbox
      docker
      #emacs
      fish
      git-lfs
      gnumake
      goose-cli
      imagemagick
      lazygit
      mise
      neofetch
      nix-output-monitor
      nixfmt-rfc-style
      nkf
      nodePkgs."@anthropic-ai/claude-code"
      nushell
      pandoc
      pnpm
      silicon
      starship
      tldr
      yazi
      # keep-sorted end
      # keep-sorted start
      astro-language-server
      elmPackages.elm-language-server
      gitlab-ci-ls
      gopls
      lua-language-server
      nixd
      pyright
      svelte-language-server
      tinymist
      typescript-language-server
      vscode-langservers-extracted
      vue-language-server
      yaml-language-server
      # keep-sorted end
      # keep-sorted start
      disable-checkout-persist-credentials
      duckgo
      firge
      firge-nerd
      ghalint
      ghatm
      gitlab-ci-verify
      octocov
      pinact
      slack-reminder
      # keep-sorted end
    ];
  };
  programs.home-manager.enable = true;
  xdg.enable = true;
}
