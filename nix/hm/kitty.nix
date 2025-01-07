{
  pkgs,
  pkgs-stable,
  config,
  theme,
  ...
}: let
  tmux = "${pkgs.tmux}/bin/tmux";
  tmux_keymaps = {
    "super+n" = "launch_silent ${tmux} new-window -a -c #{pane_current_path}";
    "super+t" = "launch_silent ${tmux} new-window -c #{pane_current_path}";
    "super+-" = "launch_silent ${tmux} split-window -l 45% -v -c #{pane_current_path}";
    # "super+\\" = "launch_silent ${tmux} split-window -l 25% -h -c #{pane_current_path}";
    # don't know why, but the slash not working in some keyboard or old kitty version?
    "super+/" = "launch_silent ${tmux} split-window -l 45% -h -c #{pane_current_path}";
    "super+z" = "launch_silent ${tmux} select-window -l";
    # "super+w" = "launch_silent ${tmux} last-pane";
    "super+w" = "launch_silent ${tmux} choose-tree -Zw -O index";
    "super+p" = "launch_silent ${tmux} display-panes -d 0";
    "super+[" = "launch_silent ${tmux} select-window -p";
    "super+]" = "launch_silent ${tmux} select-window -n";
    "super+1" = "launch_silent ${tmux} select-window -t:1";
    "super+2" = "launch_silent ${tmux} select-window -t:2";
    "super+3" = "launch_silent ${tmux} select-window -t:3";
    "super+4" = "launch_silent ${tmux} select-window -t:4";
    "super+5" = "launch_silent ${tmux} select-window -t:5";
    "super+6" = "launch_silent ${tmux} select-window -t:6";
    "super+7" = "launch_silent ${tmux} select-window -t:7";
    "super+8" = "launch_silent ${tmux} select-window -t:8";
    "super+9" = "launch_silent ${tmux} select-window -t:9";
    "super+s" = "send_text all \\xAEs";
    "ctrl+;" = "send_text all \\xAE;";
    # "ctrl+'" = "send_text \xAE'";
  };
  zj = "${pkgs.zellij}/bin/zellij";
  zellij_keymaps = {
    "super+n" = "launch_silent ${zj} action new-tab";
    "super+-" = "launch_silent ${zj} action new-pane -d down";
    "super+\\" = "launch_silent ${zj} action new-pane -d right";
    # don't know why, but the slash not working in some keyboard or old kitty version?
    "super+/" = "launch_silent ${zj} action new-pane -d right";
    "super+z" = "launch_silent ${zj} action go-to-previous-tab";
    "super+w" = "launch_silent ${zj} action focus-previous-pane";
    "super+[" = "launch_silent ${zj} action go-to-previous-tab";
    "super+]" = "launch_silent ${zj} action go-to-next-tab";
    "super+1" = "launch_silent ${zj} action go-to-tab 1";
    "super+2" = "launch_silent ${zj} action go-to-tab 2";
    "super+3" = "launch_silent ${zj} action go-to-tab 3";
    "super+4" = "launch_silent ${zj} action go-to-tab 4";
    "super+5" = "launch_silent ${zj} action go-to-tab 5";
    "super+6" = "launch_silent ${zj} action go-to-tab 6";
    "super+7" = "launch_silent ${zj} action go-to-tab 7";
    "super+8" = "launch_silent ${zj} action go-to-tab 8";
    "super+9" = "launch_silent ${zj} action go-to-tab 9";
  };
in {
  programs.kitty = {
    enable = true;
    package = pkgs-stable.kitty;
    darwinLaunchOptions = [
      "--single-instance"
      "--directory=/tmp/towry-kitty-dir"
      "--listen-on=unix:/tmp/towry-kitty-sock"
    ];
    environment = {
      MIMIC_SUPER = "1";
    };
    font = {
      name = "Berkeley Mono Nerd Font";
      size = 14;
      # name = "Iosevka";
      # size = 16;
    };
    # shellIntegration.mode = "no-rc";
    settings = {
      kitty_mod = "ctrl+shift+option";
      allow_hyperlinks = "yes";
      listen_on = "unix:/tmp/towry-kitty-sock";
      allow_remote_control = "socket-only";
      # second increase the dark in night theme
      text_composition_strategy = "1.3 20";
      dim_opacity = "1";
      tab_title_template = "\"{layout_name[:4].upper()}{fmt.fg.green}#{index}{sup.num_windows if num_windows > 1 else ''} {fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title[title.rfind('/')+1:]}\"";
      tab_powerline_style = "slanted";
      tab_separator = "\"\"";
      # background_opacity = "0.98";
      # tab_bar_style = "slant";
      tab_bar_style = "hidden";
      tab_bar_edge = "top-left";
      window_padding_width = "4 8 0 8";
      confirm_os_window_close = 1;
      remember_window_size = "yes";
      placement_strategy = "center";
      url_style = "curly";
      undercurl_style = "thin-sparse";
      cursor_shape = "block";
      disable_ligatures = "always";
      clear_all_shortcuts = "yes";
      macos_option_as_alt = "both";
      hide_window_decorations = "titlebar-only";
      # hide_window_decorations = "no";
      notify_on_cmd_finish = "unfocused";
    };
    keybindings =
      {
        "ctrl+c" = "copy_or_interrupt";
        "super+c" = "copy_to_clipboard";
        "super+v" = "paste_from_clipboard";
        "kitty_mod+u" = "input_unicode_character";
        "kitty_mod+`" = "load_config_file";
        "kitty_mod+equal" = "change_font_size all +2.0";
        "kitty_mod+minus" = "change_font_size all -2.0";
        "kitty_mod+0" = "change_font_size all 0";
        "kitty_mod+f10" = "toggle_maximized";
        "kitty_mod+f11" = "toggle_fullscreen";
        "super+o" = "hide_macos_app";
      }
      // (
        if config.programs.tmux.enable
        then tmux_keymaps
        else {}
      );
    extraConfig = ''
      globinclude kitty.d/**/*.conf
      include theme/current-theme.conf

      modify_font underline_thickness 40%
      modify_font underline_position 120%
      modify_font cell_height +1px
      ## ===
      ## 你好
      symbol_map U+4E00–U+9FFF LXGW WenKai Mono
      symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A2,U+E0A3,U+E0B0-U+E0B3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6A6,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F532,U+F500-U+FD46,U+F0001-U+F1AF0 JetBrainsMono Nerd Font

      action_alias launch_silent launch --copy-env --cwd=current --type=background
    '';
  };
  xdg.configFile = {
    "kitty/theme/" = {
      source = ../../conf/kitty/colors;
      recursive = true;
    };
    "kitty/theme.json".text = ''
      {
        "dark": "${theme.kitty.dark}",
        "light": "${theme.kitty.light}"
      }
    '';
  };
}
