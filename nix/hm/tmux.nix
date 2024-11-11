{
  pkgs,
  config,
  ...
}: let
  tmuxdot = "${config.home.homeDirectory}/.tmux";
  bash = "${pkgs.bash}/bin/bash";
in {
  home.file = {
    ".tmux/bin".source = ../../conf/tmux/bin;

    ".tmux/nix-bin/zoxide-projects.sh".text = ''
      if [[ $# -eq 1 ]]; then
        selected=$1
      else
        selected=$(${pkgs.zoxide}/bin/zoxide query -l --exclude "$PWD" | ${pkgs.path-git-format}/bin/path-git-format --filter --no-bare -f"{path} [{branch}]" | awk -v home="$HOME" '{gsub(home, "~"); print}' | ${pkgs.fzf}/bin/fzf --reverse --preview-window="down,30%,border-top" --tiebreak=index -1 -0 --exact --preview "echo {} | awk -F '[' '{print \$1}' | awk -v home=\"\$HOME\" '{sub(/^~/,home)};1' | xargs -I % ${pkgs.eza}/bin/eza --color=always --icons=auto --group-directories-first --git --no-user --no-quotes --git-repos %" | awk -v home="$HOME" '{sub(/^~/, home)};1')
      fi

      if [[ -z $selected ]]; then
        exit 0
      fi

      selected=$(echo $selected | awk -F '[' '{print $1}' | awk '{$1=$1;print}')
      selected_name="''${selected##*/}"

      if [[ -z $TMUX ]]; then
        tmux new-session -s $selected_name -c $selected
        exit 0
      fi

      if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c $selected
      fi

      tmux switch-client -t "$selected_name"
    '';
    ".tmux/nix-bin/commands.sh".text = ''
      selected_label=$(${pkgs.jq}/bin/jq -r '.[].label' ${tmuxdot}/commands.json | ${pkgs.fzf}/bin/fzf --prompt=' Run: ' --preview-window="right,border-left,<60(bottom,30%,border-top)" --preview '${pkgs.bat}/bin/bat --wrap auto -lsh --style=numbers --color=always <(jq -r ".[{n}] | .script" ${tmuxdot}/commands.json)')
      selected_script=$(${pkgs.jq}/bin/jq -r ".[] | select(.label == \"$selected_label\") | .script" ${tmuxdot}/commands.json)
      if [ -n "$selected_script" ]; then
        export PATH=${config.home.homeDirectory}/.nix-profile/bin:$PATH
        ${pkgs.bash}/bin/bash "$selected_script" && exit
      fi
    '';
    # >commands
    ".tmux/commands.json".text = ''
      [
        {
          "label": "Reload tmux config",
          "script": "${tmuxdot}/bin/reload-tmux-config.sh"
        },
        {
          "label": "Show tmux config",
          "script": "${tmuxdot}/bin/bat-tmux-config.sh"
        },
        {
          "label": "Kill Current Session",
          "script": "${tmuxdot}/bin/_kill-session.sh"
        }
      ]
    '';
  };
  programs.tmux = {
    enable = true;
    historyLimit = 20000;
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    prefix = "C-z";
    sensibleOnTop = false;
    terminal = "tmux-256color";
    shell = "${pkgs.fish}/bin/fish";
    # https://github.com/tmuxinator/tmuxinator
    tmuxinator.enable = false;
    # https://github.com/tmux-python/tmuxp
    tmuxp.enable = false;
    plugins = with pkgs; [];
    extraConfig = ''
      #== env
      if-shell "echo $TERM | grep alacritty" "set-option -sa terminal-overrides ',alacritty:Tc'"
      if-shell "echo $TERM | grep alacritty" 'set-option -ga terminal-features ",alacritty:usstyle"'
      if-shell "echo $TERM | grep xterm" "set-option -sa terminal-overrides ',xterm*:Tc'"
      if-shell "echo $TERM | grep xterm" 'set-option -ga terminal-features ",xterm*:usstyle"'

      %if #{>=:#{version},3.3}
        set-option -g allow-passthrough on
      %endif

      set -g update-environment \
          "DISPLAY\
          SSH_ASKPASS\
          TERM\
          TERM_PROGRAM\
          EDITOR\
          TMUX_IS_POPUP\
          fish_pid\
          FZF_DEFAULT_OPTS\
          SSH_TTY\
          SSH_CONNECTION\
          SSH_AGENT_PID\
          SSH_AUTH_SOCK\
          MIMIC_SUPER\
          XDG_CONFIG_HOME\
          XDG_CACHE_HOME\
          XDG_DATA_HOME\
          "

      #====== Settings
      ## must be on, otherwise float won't close
      set -g detach-on-destroy on
      set -g renumber-windows on
      set -sg escape-time 0
      set -g display-time 1500
      set -g remain-on-exit off
      set -g allow-rename off
      set -g automatic-rename on
      set -g automatic-rename-format '#{b:pane_current_path}'
      setw -g aggressive-resize on
      # Set parent terminal title to reflect current window in tmux session
      set -g set-titles on
      # set -g set-titles-string "#I:#W"
      set -g set-titles-string "#T - #W"
      # Start index of window/pane with 1, because we're humans, not computers
      # ====================================
      # ============ key bindings
      bind c new-window -c "#{pane_current_path}"
      bind r command-prompt -I "#{window_name}" "rename-window '%%'"
      bind R command-prompt -I "#{session_name}" "rename-session '%%'"
      bind C-n command-prompt -p "Enter session:" "new-session -A -s '%%'"
      ## split a pane and run command
      bind _ command-prompt -p "split vertical and run:" "split-window -p 40 -c '#{pane_current_path}' 'tmux select-pane -T \"%%\" >/dev/null; tmux last-pane >/dev/null; %% ; cat'"
      bind \; command-prompt
      ## rerun current pane
      bind ! respawn-pane -k -c "#{pane_current_path}"
      ## rerun a pane
      bind @ command-prompt -p 'respawn a pane(I):' 'respawn-pane -k -t %%'
      ## save current history to a buffer to ${config.home.homeDirectory}/local-tmux.history
      bind C-b command-prompt -p 'save history to filename:' -I '${config.home.homeDirectory}/local-tmux.history' 'capture-pane -S - ; save-buffer %1 ; delete-buffer'
      bind ? list-keys

      ## Split panes
      bind / split-window -h -l 50% -c "#{pane_current_path}"
      bind - split-window -v -l 50% -c "#{pane_current_path}"
      bind + select-layout even-vertical
      bind = select-layout even-horizontal
      # space is next-layout
      bind -r enter previous-layout
      bind C-h select-layout main-horizontal
      bind C-v select-layout main-vertical

      # cycle thru MRU tabs
      bind -r Tab last-window
      bind -r C-s switch-client -l
      bind -r C-o swap-pane -D

      ### is-vim ?
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n C-h if-shell "$is_vim" 'send-keys C-h'  'select-pane -LZ'
      bind-key -n C-j if-shell "$is_vim" 'send-keys C-j'  'select-pane -DZ'
      bind-key -n C-k if-shell "$is_vim" 'send-keys C-k'  'select-pane -UZ'
      bind-key -n C-l if-shell "$is_vim" 'send-keys C-l'  'select-pane -RZ'
      bind -r C-h select-pane -LZ
      bind -r C-j select-pane -DZ
      bind -r C-k select-pane -UZ
      bind -r C-l select-pane -RZ
      bind -n M-0 select-pane -lZ

      bind-key -n M-h if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 15'
      bind-key -n M-j if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 15'
      bind-key -n M-k if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 15'
      bind-key -n M-l if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 15'

      bind C-g popup -E -w 80% -h 60% "${pkgs.bash}/bin/bash ${tmuxdot}/nix-bin/commands.sh"

      bind z resize-pane -x 50% -y 50%
      ## Zoom pane
      # strange <prefix><C-z> causing blank window, so we map it to resize-pane
      bind C-z resize-pane -Z
      # bind F2 to root table
      bind -T root F2 resize-pane -Z

      ## -------- reserved
      # synchronize mode (toggle)
      # bind -r C-e set-window-option synchronize-panes
      # Link window
      # bind L command-prompt -p "Link window from (session:window): " "link-window -s %% -a"

      ## Destroy
      bind x run-shell "${config.home.homeDirectory}/.tmux/bin/tmux-kill-pane.sh"
      bind X confirm-before -p "kill window? (y/n)" kill-window
      bind C-q confirm-before -p "kill other windows? (y/n)" "kill-window -a"
      bind Q confirm-before -p "kill-session #S? (y/n)" kill-session
      bind C-e run-shell "${config.home.homeDirectory}/.tmux/bin/vim-edit-tmux-output.sh"

      ## Merge session
      bind C-u command-prompt -p "Session to merge with: " \
        "run-shell 'yes | head -n #{session_windows} | xargs -I {} -n 1 tmux movew -t %%'"
      ## Detach from session
      bind-key d detach
      bind D if -F '#{session_many_attached}' \
          'confirm-before -p "Detach other clients? (y/n)" "detach -a"' \
          'display "Session has only 1 client attached"'

      ## Hide status bar on demand
      bind M-s if -F '#{s/off//:status}' 'set status off' 'set status on'

      bind -T root F12  set prefix None \; set key-table off \; if -F '#{pane_in_mode}' 'send-keys -X cancel' \; refresh-client -S \;
      bind -T off F12 set -u prefix \; set -u key-table \; refresh-client -S

      # ===== popup & commands
      ## <prefix>w to switch windows.
      bind C-w run "${config.home.homeDirectory}/.tmux/bin/windows.sh switch"
      ## <prefix>s to switch sessions
      bind s run "${config.home.homeDirectory}/.tmux/bin/session.sh switch"
      bind S run "${config.home.homeDirectory}/.tmux/bin/session.sh kill"
      bind C-p run "${config.home.homeDirectory}/.tmux/bin/pane.sh switch"
      ## start new session from folder.
      bind y popup -E -w 80% -h 60% "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.tmux/nix-bin/zoxide-projects.sh"
      bind f run "${config.home.homeDirectory}/.tmux/bin/tmux-scratch-toggle.tmux"
      bind C-f run "${bash} ${config.home.homeDirectory}/.tmux/bin/tmux-scratch-toggle.tmux toggle"
      bind : run "${config.home.homeDirectory}/.tmux/bin/command.sh"
      bind & run "${config.home.homeDirectory}/.tmux/bin/process.sh"


      # ================================================
      # Copy mode, scroll and clipboard
      # ==
      set -g @copy_use_osc52_fallback on
      # Prefer vi style key table
      setw -g mode-keys vi
      bind -r P paste-buffer
      # bind C-p choose-buffer
      # trigger copy mode by
      bind -r [ copy-mode
      # Scroll up/down by 1 line, half screen, whole screen
      # bind -T copy-mode-vi M-Up              send-keys -X scroll-up
      # bind -T copy-mode-vi M-Down            send-keys -X scroll-down
      # bind -T copy-mode-vi M-PageUp          send-keys -X halfpage-up
      # bind -T copy-mode-vi M-PageDown        send-keys -X halfpage-down
      bind -T copy-mode-vi PageDown          send-keys -X page-down
      bind -T copy-mode-vi PageUp            send-keys -X page-up
      ## Copy
      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      yank="${config.home.homeDirectory}/.tmux/bin/yank.sh"
      # Copy selected text
      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "$yank"
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "$yank"
      bind -T copy-mode-vi Y send-keys -X copy-line \; run "tmux save-buffer - | $yank"
      bind-key -T copy-mode-vi D send-keys -X copy-end-of-line \; run "tmux save-buffer - | $yank"
      bind -T copy-mode-vi C-j send-keys -X copy-pipe-and-cancel "$yank"
      bind-key -T copy-mode-vi A send-keys -X append-selection-and-cancel \; run "tmux save-buffer - | $yank"
      # Copy selection on drag end event, but do not cancel copy mode and do not clear selection
      # clear select on subsequence mouse click
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe "$yank"
      bind -T copy-mode-vi MouseDown1Pane select-pane \; send-keys -X clear-selection

      # ===============================================
      ## UI
      set -g pane-border-status bottom
      set -g status-interval 1
      set -g status on
      set -g status-left-length 100
      set -g status-right-length 300
      set -g status-justify left
      set-window-option -g status-position top
      set -g message-style fg=black,bg=blue
      set -g message-command-style fg=black,bg=blue
      set -g status-style bg=default,fg=yellow
      set -g pane-border-style bg=default,fg=yellow
      set -g pane-active-border-style bg=default,fg=blue
      set -g display-panes-colour black
      set -g display-panes-active-colour cyan
      #+--- Bars ---+
      set -g status-left "#[bold] #S "
      set -g status-right "#[bold] #h "
      #+--- Windows ---+
      set -g window-status-format " #I·#W#{?window_zoomed_flag,##Z,}#{?window_end_flag, , }"
      set -g window-status-current-format "#[bg=blue,fg=black,bold] #I·#W#{?window_zoomed_flag,##Z,}#{?window_end_flag, , }"
      set -g window-status-separator "#[fg=colour8]│"
      # ========== End UI
    '';
  };
}
