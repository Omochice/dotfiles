{
  pkgs,
  user,
  home,
  ...
}:
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
      actionlint
      asciinema
      asciinema-agg
      ast-grep
      awscli2
      bat
      btop
      cachix
      cargo
      ccusage
      clang-tools
      claude-code
      curl
      d2
      delta
      devbox
      direnv
      docker
      editorconfig-checker
      fastfetch
      fd
      #emacs
      fish
      fzf
      gh
      ghq
      git-cliff
      git-lfs
      glab
      glow
      gnumake
      goose-cli
      gotools
      hadolint
      hyperfine
      imagemagick
      jnv
      jq
      lazydocker
      lazygit
      lsd
      mise
      mkcert
      mmv-go
      neofetch
      nix-output-monitor
      nixfmt-rfc-style
      nkf
      nushell
      pandoc
      pastel
      pnpm
      reviewdog
      ripgrep
      sd
      shfmt
      silicon
      speedtest-cli
      starship
      tldr
      tokei
      typos
      unar
      uv
      vim-startuptime
      yazi
      # keep-sorted end
      # keep-sorted start
      astro-language-server
      biome
      efm-langserver
      elmPackages.elm-language-server
      gitlab-ci-ls
      gopls
      lua-language-server
      nixd
      pyright
      svelte-language-server
      tinymist
      typescript-language-server
      typos-lsp
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
