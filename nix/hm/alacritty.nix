{
  pkgs,
  config,
  ...
}: let
  tmuxprg = "${pkgs.tmux}/bin/tmux";
  kanagawa_dragon = {
    colors.primary = {
      background = "#181616";
      foreground = "#c5c9c5";
    };
    colors.cursor = {
      cursor = "#c8c093";
      text = "#181616";
    };
    colors.selection = {
      background = "#2d4f67";
      foreground = "#c8c093";
    };
    colors.normal = {
      black = "#0d0c0c";
      blue = "#8ba4b0";
      cyan = "#8ea4a2";
      green = "#8a9a7b";
      magenta = "#a292a3";
      red = "#c4746e";
      white = "#C8C093";
      yellow = "#c4b28a";
    };
    colors.bright = {
      # inactive tab bg
      black = "#96969c";
      blue = "#7FB4CA";
      cyan = "#7AA89F";
      green = "#87a987";
      magenta = "#938AA9";
      red = "#E46876";
      white = "#c5c9c5";
      yellow = "#E6C384";
    };
    colors.indexed_colors = [
      {
        index = 16;
        color = "#ffa066";
      }
      {
        index = 17;
        color = "#ff5d62";
      }
    ];
  };
  tmuxKeyboard = {
    # Named keys: https://docs.rs/winit/latest/winit/keyboard/enum.NamedKey.html
    keyboard.bindings = [
      {
        key = "n";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "new-window"
            "-c"
            "#{pane_current_path}"
          ];
        };
      }
      {
        key = "-";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "split-window"
            "-v"
            "-c"
            "#{pane_current_path}"
          ];
        };
      }
      {
        key = "/";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "split-window"
            "-h"
            "-c"
            "#{pane_current_path}"
          ];
        };
      }
      ## window selection
      {
        key = "z";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-l"
          ];
        };
      }
      {
        # previous
        key = "[";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-p"
          ];
        };
      }
      {
        # next
        key = "]";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-n"
          ];
        };
      }
      {
        key = "Key1";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:1"
          ];
        };
      }
      {
        key = "Key2";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:2"
          ];
        };
      }
      {
        key = "Key3";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:3"
          ];
        };
      }
      {
        key = "Key4";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:4"
          ];
        };
      }
      {
        key = "Key5";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:5"
          ];
        };
      }
      {
        key = "Key6";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:6"
          ];
        };
      }
      {
        key = "Key7";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:7"
          ];
        };
      }
      {
        key = "Key8";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:8"
          ];
        };
      }
      {
        key = "Key9";
        mods = "Command";
        command = {
          program = tmuxprg;
          args = [
            "select-window"
            "-t:9"
          ];
        };
      }
    ];
  };
in {
  programs.alacritty = {
    enable = true;
    settings =
      {
        import = [
          "${config.xdg.configHome}/alacritty/tmux.toml"
        ];
        font = {
          size = 16;
          offset.y = 0;
          glyph_offset = {
            x = 1;
            y = 0;
          };
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
        };
        shell.program = "${pkgs.fish}/bin/fish";
        colors.draw_bold_text_with_bright_colors = true;
        mouse.hide_when_typing = true;
        selection = {
          save_to_clipboard = true;
        };
        window = {
          dynamic_padding = true;
          dynamic_title = true;
          opacity = 1;
          blur = false;
          decorations = "Buttonless";
          option_as_alt = "Both";
          startup_mode = "Maximized";
        };
      }
      // (
        if config.programs.tmux.enable
        then tmuxKeyboard
        else {}
      )
      // kanagawa_dragon;
  };

  xdg.configFile."alacritty/tmux.toml" = {
    enable = true;
    text = ''
      [env]
      MIMIC_SUPER = "0xAE"
      [[keyboard.bindings]]
      key = "S"
      mods = "Super"
      chars = "\u00aes"
      [[keyboard.bindings]]
      key = "Semicolon"
      mods = "Control"
      chars = "\u00ae;"
      [[keyboard.bindings]]
      key = "'"
      mods = "Control"
      chars = "\u00ae'"
    '';
  };
}
