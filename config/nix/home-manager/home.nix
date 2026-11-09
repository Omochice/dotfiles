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
    ../modules/home-manager/my-jj.nix
    # keep-sorted start
    ../../adroit/default.nix
    ../../android/default.nix
    ../../bat/default.nix
    ../../brew/default.nix
    ../../browser/default.nix
    ../../claude/default.nix
    ../../clipboard/default.nix
    ../../colima/default.nix
    ../../devbox/default.nix
    ../../direnv/default.nix
    ../../doom/default.nix
    ../../felis/default.nix
    ../../fish/default.nix
    ../../gh-triage/default.nix
    ../../gh/default.nix
    ../../git-wt/default.nix
    ../../git/default.nix
    ../../glab-cli/default.nix
    ../../jj/default.nix
    ../../karabiner/default.nix
    ../../lazygit/default.nix
    ../../lsd/default.nix
    ../../moon/default.nix
    ../../neru/default.nix
    ../../nix/default.nix
    ../../npm/default.nix
    ../../nushell/default.nix
    ../../nvim/default.nix
    ../../ollama/default.nix
    ../../omniwm/default.nix
    ../../paru/default.nix
    ../../pnpm/default.nix
    ../../power/default.nix
    ../../ptpython/default.nix
    ../../rumdl/default.nix
    ../../sketchybar/default.nix
    ../../starship/default.nix
    ../../wezterm/default.nix
    ../../yazi/default.nix
    # ../../zathura/default.nix
    ../../zk/default.nix
    ../../zoxide/default.nix
    # keep-sorted end
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
    sessionVariables.LANG = "en_US.UTF-8";
    packages = with pkgs; [
      # keep-sorted start
      age
      ansifilter
      asciinema
      asciinema-agg
      ast-grep
      awscli2
      bat
      btop
      cachix
      cclens
      clang-tools
      curl
      delta
      deno
      devbox
      docker
      docker-buildx
      duckdb
      fastfetch
      fd
      fish
      fzf
      gh
      git-cliff
      git-lfs
      github-copilot-cli
      glab
      glow
      gnumake
      gnupg1
      go_latest
      graphviz
      hyperfine
      imagemagick
      jnv
      jq
      lazydocker
      lsd
      mise
      mkcert
      mmv-go
      neovim-omochice
      nh
      nix-search-cli
      nixfmt
      nkf
      nodejs_latest
      nur.disable-checkout-persist-credentials
      nur.dockerfile-pin
      nur.duckgo
      nur.firge
      nur.firge-nerd
      nur.ghatm
      nur.ghq
      nur.lazygit
      nur.pinact
      nur.slack-reminder
      nur.upm
      nur.vim-startuptime
      nushell
      pastel
      pnpm
      ripgrep
      rustup
      sd
      sops
      speedtest-cli
      starship
      tldr
      tokei
      typos
      unar
      uv
      xleak
      yazi
      zmx
      # keep-sorted end
      # keep-sorted start
      astro-language-server
      biome
      elmPackages.elm-language-server
      gopls
      ls-lint
      lua-language-server
      nixd
      nur.gitlab-ci-ls
      oxlint
      pyright
      rumdl
      stylua
      svelte-language-server
      taplo
      tinymist
      typescript
      typos-lsp
      vscode-langservers-extracted
      vue-language-server
      yaml-language-server
      # keep-sorted end
    ];
  };
  programs.home-manager.enable = true;
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = pkgs.stdenv.hostPlatform.isDarwin;
  };
  xdg.enable = true;
}
