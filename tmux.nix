# tmux.nix
{ config, pkgs, lib, ... }:
let tmuxPlugins = with pkgs.tmuxPlugins; [ sensible prefix-highlight ];
in {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    aggressiveResize = true;
    historyLimit = 20000;

    plugins = tmuxPlugins;

    extraConfig = ''
      # prefix
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      set -s escape-time 0
      set -g focus-events on
      set -g renumber-windows on

      set -ga terminal-overrides ",*:Tc"

      # clipboard
      set -g set-clipboard on
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "clip"
      bind -T copy-mode-vi Y send -X copy-pipe-and-cancel "clip"

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 5

      bind c new-window -c "#{pane_current_path}"
      bind x kill-pane
      bind X confirm-before -p "kill-window #W? (y/n)" kill-window

      set -g status on
      set -g status-justify centre
      set -g status-bg colour0
      set -g status-fg colour250

      set -g window-status-current-style "bold,fg=colour231,bg=colour4"
      set -g window-status-style "fg=colour244,bg=colour0"

      set -g status-left-length 30
      set -g status-right-length 60
      set -g status-left  "#[bold] #S "
      set -g status-right '#{prefix_highlight}'

      set -g @prefix_highlight_fg 'colour232'
      set -g @prefix_highlight_bg 'colour220'
      set -g @prefix_highlight_output_prefix ' ⌃ '
      set -g @prefix_highlight_show_copy_mode 'on'
      set -g @prefix_highlight_copy_mode_attr 'fg=colour232,bg=colour45,bold'

      set -g status-keys vi
      set -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle

      # 同一コマンド送信（複数ペインへ同時入力）
      bind a set -w synchronize-panes

      # 新しい tmux を現在のセッションにぶつけない保険
      set -g detach-on-destroy on
    '';
  };

  home.packages = [
    (pkgs.writeShellScriptBin "ta" ''
      # usage: ta <session_name>
      set -eu
      s="''${1:-work}"
      if tmux has-session -t "$s" 2>/dev/null; then
        exec tmux attach -t "$s"
      else
        exec tmux new -s "$s"
      fi
    '')
  ];
}

