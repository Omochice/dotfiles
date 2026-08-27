{
  pkgs,
  user,
  home,
  ...
}:
{
  imports = [
    ../modules/home-manager/dotfiles-dir.nix
    ../modules/home-manager/my-git-wt.nix
    # keep-sorted start
    ../../alacritty/default.nix
    ../../android/default.nix
    ../../bat/default.nix
    ../../brew/default.nix
    ../../browser/default.nix
    ../../claude/default.nix
    ../../clipboard/default.nix
    ../../colima/default.nix
    ../../devbox/default.nix
    ../../direnv/default.nix
    # ../../doom/default.nix
    ../../fish/default.nix
    ../../gh-triage/default.nix
    ../../gh/default.nix
    ../../git-wt/default.nix
    ../../git/default.nix
    ../../glab-cli/default.nix
    ../../karabiner/default.nix
    ../../lazygit/default.nix
    ../../lsd/default.nix
    ../../mise/default.nix
    ../../moon/default.nix
    ../../nix/default.nix
    ../../npm/default.nix
    ../../nushell/default.nix
    ../../nvim/default.nix
    ../../ollama/default.nix
    ../../paru/default.nix
    ../../pnpm/default.nix
    ../../power/default.nix
    ../../ptpython/default.nix
    ../../rumdl/default.nix
    ../../sketchybar/default.nix
    ../../starship/default.nix
    ../../tmux/default.nix
    ../../wezterm/default.nix
    ../../yazi/default.nix
    # ../../zathura/default.nix
    ../../zk/default.nix
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
    sessionPath = [ "${home}/.local/bin" ];
    packages = with pkgs; [
      # keep-sorted start
      abduco
      age
      ansifilter
      asciinema
      asciinema-agg
      ast-grep
      awscli2
      bat
      btop
      cachix
      cargo
      clang-tools
      curl
      delta
      deno
      devbox
      docker
      docker-buildx
      duckdb
      editorconfig-checker
      fastfetch
      fd
      fish
      fzf
      gh
      ghq
      git-cliff
      git-lfs
      github-copilot-cli
      glab
      glow
      gnumake
      gnupg1
      graphviz
      hadolint
      hyperfine
      imagemagick
      jnv
      jq
      lazydocker
      lazygit
      llm-pkgs.ccusage
      lsd
      mise
      mkcert
      mmv-go
      neovim-omochice
      nix-output-monitor
      nixfmt
      nkf
      nodejs_24
      nushell
      pandoc
      pastel
      pnpm
      reviewdog
      ripgrep
      sd
      shfmt
      sops
      speedtest-cli
      starship
      tldr
      tokei
      typos
      typstyle
      unar
      uv
      vim-startuptime
      xcpretty
      yazi
      # keep-sorted end
      # keep-sorted start
      astro-language-server
      biome
      elmPackages.elm-language-server
      gitlab-ci-ls
      gopls
      ls-lint
      lua-language-server
      nixd
      oxlint
      pyright
      rumdl
      stylua
      svelte-language-server
      taplo
      tinymist
      typescript-go
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
      ghatm
      octocov
      pinact
      slack-reminder
      # keep-sorted end
    ];
  };
  programs.home-manager.enable = true;
  xdg.enable = true;
}
