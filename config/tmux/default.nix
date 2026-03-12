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
    shell = "${pkgs.lib.getExe pkgs.fish}";
    terminal = "tmux-256color";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    mouse = false;
    historyLimit = 10000;

    extraConfig = ''
      bind-key -n M-c new-window -c "#{pane_current_path}"
      bind-key -n M-n next-window
      bind-key -n M-N previous-window
      bind-key -n M-- split-window -v -c "#{pane_current_path}"
      bind-key -n M-¥ split-window -h -c "#{pane_current_path}"
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-k select-pane -U
      bind-key -n M-l select-pane -R
      bind-key -n M-Left resize-pane -L 3
      bind-key -n M-Down resize-pane -D 3
      bind-key -n M-Up resize-pane -U 3
      bind-key -n M-Right resize-pane -R 3
      bind-key -n M-Q kill-pane
      bind-key -n M-q copy-mode
      bind-key -n 'M-[' copy-mode
      bind-key -n M-1 select-window -t 1
      bind-key -n M-2 select-window -t 2
      bind-key -n M-3 select-window -t 3
      bind-key -n M-4 select-window -t 4
      bind-key -n M-5 select-window -t 5
      bind-key -n M-6 select-window -t 6
      bind-key -n M-7 select-window -t 7
      bind-key -n M-8 select-window -t 8
      bind-key -n M-9 select-window -t 9
      bind-key -n M-/ copy-mode \; send-keys /
      bind-key -n M-v paste-buffer

      set -g set-clipboard on
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi V send-keys -X select-line
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi Escape send-keys -X cancel

      # --- Appearance (Sonokai) ---
      set -g status-position top
      set -g status-style "fg=${colors.fg}"
      set -g status-left ""
      set -g status-right ""
      set -g window-status-format " #I: #W "
      set -g window-status-current-format " #I: #W "
      set -g window-status-current-style "bg=${colors.cyan},fg=${colors.selFg}"
      set -g window-status-style "fg=${colors.fg}"
      set -g pane-border-style "fg=${colors.black}"
      set -g pane-active-border-style "fg=${colors.cyan}"
      set -g mode-style "bg=${colors.selBg},fg=${colors.selFg}"
      set -g message-style "bg=${colors.bg},fg=${colors.fg}"
      set -g renumber-windows on
    '';
  };
}
