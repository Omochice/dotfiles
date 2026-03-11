{ pkgs, ... }:
let
  colors = {
    bg = "#000000";
    fg = "#e4e3e1";
    selBg = "#f0c66f";
    selFg = "#1f1e1c";
    black = "#1f1e1c";
    cyan = "#81d0c9";
  };
in
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;
    historyLimit = 10000;

    extraConfig = ''
      # --- Keybindings (ALT modifier, matching WezTerm) ---
      bind -n M-c new-window -c "#{pane_current_path}"
      bind -n M-n next-window
      bind -n M-N previous-window
      bind -n M-- split-window -v -c "#{pane_current_path}"
      bind -n 'M-\' split-window -h -c "#{pane_current_path}"
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
      bind -n M-Left resize-pane -L 3
      bind -n M-Down resize-pane -D 3
      bind -n M-Up resize-pane -U 3
      bind -n M-Right resize-pane -R 3
      bind -n M-Q kill-pane
      bind -n M-q copy-mode
      bind -n 'M-[' copy-mode
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9
      bind -n M-/ copy-mode \; send-keys /
      bind -n M-v paste-buffer

      # --- Copy mode (vi) with OSC 52 clipboard ---
      set -g set-clipboard on
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind -T copy-mode-vi Escape send-keys -X cancel

      # --- Appearance (Sonokai) ---
      set -g status-position bottom
      set -g status-style "bg=${colors.bg},fg=${colors.fg}"
      set -g status-left ""
      set -g status-right ""
      set -g window-status-format " #I: #W "
      set -g window-status-current-format " #I: #W "
      set -g window-status-current-style "bg=${colors.cyan},fg=${colors.selFg}"
      set -g window-status-style "bg=${colors.bg},fg=${colors.fg}"
      set -g pane-border-style "fg=${colors.black}"
      set -g pane-active-border-style "fg=${colors.cyan}"
      set -g mode-style "bg=${colors.selBg},fg=${colors.selFg}"
      set -g message-style "bg=${colors.bg},fg=${colors.fg}"
      set -g renumber-windows on
    '';
  };
}
