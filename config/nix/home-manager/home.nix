{
  pkgs,
  user,
  home,
  inputs,
  ...
}:
let
  llm-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ../modules/home-manager/my-claude-code.nix
    ../modules/home-manager/my-git-wt.nix
    # keep-sorted start
    ../../claude/default.nix
    ../../colima/default.nix
    ../../deno/default.nix
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
    ../../mise/default.nix
    ../../nix/default.nix
    ../../nushell/default.nix
    ../../nvim/default.nix
    ../../ollama/default.nix
    ../../rumdl/default.nix
    ../../sketchybar/default.nix
    ../../starship/default.nix
    ../../wezterm/default.nix
    ../../yazi/default.nix
    ../../zathura/default.nix
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
    packages = with pkgs; [
      # keep-sorted start
      abduco
      actionlint
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
      d2
      delta
      deno
      devbox
      direnv
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
      goose-cli
      gotools
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
