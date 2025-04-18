{
  config,
  pkgs,
  ...
}:
let
  isServer = false;
in
{
  programs = {
    zellij = {
      enable = false;
      enableFishIntegration = true;
      exitShellOnExit = true;
      attachExistingSession = true;
    };
    fish = {
      interactiveShellInit = "_update_zellij_tab_name";
      functions."_update_zellij_tab_name" = {
        onEvent = "fish_prompt";
        onVariable = "PWD";
        body = ''
          if string match -q "$HOME/workspace/*" "$PWD" || string match -q "$HOME/.dotfiles/*" "$PWD"
              if test -d .git; or git rev-parse --git-dir > /dev/null 2>&1
                set -l repo_name (basename $PWD)
                set -l current_branch (git branch --show-current)

                if test -n current_branch
                    set current_branch ":$current_branch"
                end

                set -l tab_title "$repo_name$current_branch"
                if test -n "$ZELLIJ"
                    command nohup zellij action rename-tab "$tab_title" >/dev/null 2>&1
                end
              end
          end
        '';
      };
    };
  };
  xdg.configFile = {
    "zellij/config.kdl".text = ''
      load_plugins {
        "file:${pkgs.zjstatus}/bin/zjframes.wasm" {
          hide_frame_except_for_search     "true"
          hide_frame_except_for_scroll     "true"
          hide_frame_except_for_fullscreen "true"
        }
      }

      keybinds clear-defaults=true {
          locked {
              bind "Ctrl g" { SwitchToMode "Normal"; }
          }
          move {
              bind "Backspace" { SwitchToMode "Tmux"; }
              bind "n" "Tab" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "h" "Left" { MovePane "Left"; }
              bind "j" "Down" { MovePane "Down"; }
              bind "k" "Up" { MovePane "Up"; }
              bind "l" "Right" { MovePane "Right"; }
          }
          scroll {
              bind "Backspace" { SwitchToMode "Tmux"; }
              bind "e" { EditScrollback; SwitchToMode "Normal"; }
              bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "Ctrl d" { HalfPageScrollDown; }
              bind "Ctrl u" { HalfPageScrollUp; }
          }
          search {
              bind "Backspace" { SwitchToMode "Tmux"; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
              bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
              bind "/" { SwitchToMode "EnterSearch"; }
              bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "n" { Search "down"; }
              bind "p" { Search "up"; }
              bind "N" { Search "up"; }
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "w" { SearchToggleOption "Wrap"; }
              bind "o" { SearchToggleOption "WholeWord"; }
          }
          entersearch {
              bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
              bind "Enter" { SwitchToMode "Search"; }
          }
          renametab {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
          }
          renamepane {
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
          }
          session {
              bind "d" { Detach; }
              bind "Ctrl c" { SwitchToMode "Normal"; }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating false
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
              bind "p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating false
                      move_to_focused_tab true
                  };
                  SwitchToMode "Normal"
              }
          }
          tmux {
              bind "Ctrl g" { SwitchToMode "Locked"; }
              bind "&" { SwitchToMode "Scroll"; }
              bind "*" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "/" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "Ctrl n" { NewPane; SwitchToMode "Normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
              bind "Ctrl b" { TogglePaneFrames; SwitchToMode "Normal"; }
              bind "P" { SwitchToMode "RenamePane"; PaneNameInput 0; }
              bind "T" { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "r" { SwitchToMode "Resize"; }
              bind "f" { ToggleFloatingPanes; SwitchToMode "Normal"; }
              bind "w" {
                LaunchOrFocusPlugin "zellij:session-manager" {
                  floating true
                  move_to_focused_tab false
                };
                SwitchToMode "Normal";
              }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
              bind "c" { NewTab; SwitchToMode "Normal"; }
              bind "X" { CloseTab; SwitchToMode "Normal"; }
              bind "[" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind "]" { GoToNextTab; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "9" { GoToTab 9; SwitchToMode "Normal"; }
              bind "Ctrl ;" { Write 58; SwitchToMode "Normal"; }
              bind "Tab" { ToggleTab; SwitchToMode "Normal"; }
              bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "j"  { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
              bind "m" { SwitchToMode "Move"; }
              bind "Ctrl o" { FocusNextPane; }
              bind "Ctrl s" { SwitchToMode "Session"; }
              bind "Space" { NextSwapLayout; }
              bind "x" { CloseFocus; SwitchToMode "Normal"; }
          }
          normal {
              bind "Ctrl z" { SwitchToMode "Tmux"; }
              bind "Alt Left" { GoToPreviousTab; }
              bind "Alt Right" { GoToNextTab; }
              bind "Super t" { ToggleFloatingPanes; }
              bind "Super p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  };
              }
              bind "Super [" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind "Super ]" { GoToNextTab; SwitchToMode "Normal"; }
              bind "Super z" { ToggleTab; }
              bind "Super n" {
                  NewTab {
                        cwd "${config.home.homeDirectory}"
                        name "~"
                        layout "default"
                  }
              }
              bind "Super 1" { GoToTab 1; }
              bind "Super 2" { GoToTab 2; }
              bind "Super 3" { GoToTab 3; }
              bind "Super 4" { GoToTab 4; }
              bind "Super 5" { GoToTab 5; }
              bind "Super 6" { GoToTab 6; }
              bind "Super 7" { GoToTab 7; }
              bind "Super 8" { GoToTab 8; }
              bind "Super 9" { GoToTab 9; }
              bind "Super r" { SwitchToMode "Resize"; }
              bind "Super -" { NewPane "Down"; }
              bind "Super /" { NewPane "Right"; }
              bind "Super w" {
                LaunchOrFocusPlugin "zellij:session-manager" {
                  floating true
                  move_to_focused_tab false
                };
                SwitchToMode "Normal";
              }
          }
          shared_except "locked" {
              bind "Ctrl h" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "left";
                  };
              }
              bind "Ctrl j" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "down";
                  };
              }
              bind "Ctrl k" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "up";
                  };
              }
              bind "Ctrl l" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "move_focus";
                      payload "right";
                  };
              }
              bind "Alt h" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "left";
                  };
              }
              bind "Alt j" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "down";
                  };
              }
              bind "Alt k" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "up";
                  };
              }
              bind "Alt l" {
                  MessagePlugin "file:${pkgs.vim-zellij-navigator}/bin/vim-zellij-navigator.wasm" {
                      name "resize";
                      payload "right";
                  };
              }
          }
          shared_except "locked" "normal" {
              bind "Enter" "Esc" { SwitchToMode "Normal"; }
          }
      }

      ui {
          pane_frames {
              hide_session_name false
              rounded_corners false
          }
      }

      themes {
          modus_dark {
            fg "#ffffff"
            bg "#7030af"
            black "#131e1e"
            red "#ff5f5f"
            green "#7030af"
            yellow "#fec43f"
            blue "#3548cf"
            magenta "#feacd0"
            cyan "#00eff0"
            white "#ffffff"
            orange "#ff9580"
          }
          leaf {
            fg "#fcfff6"
            bg "#2e2c2f"
            black "#1e1c1f"
            red "#d6797a"
            green "#729B79"
            yellow "#e3c882"
            blue "#005078"
            magenta "#b798e6"
            cyan "#77c5da"
            white "#fcfff6"
            orange "#d68c67"
          }
          kanagawa_wave {
              bg "#223249"
              fg "#54546D"
              black "#181816"
              red "#C34043"
              green "#76946A"
              yellow "#C0A36E"
              blue "#7E9CD8"
              magenta "#957FB8"
              cyan "#6A9589"
              white "#54546D"
              orange "#FFA066"
          }
          kanagawa_dragon {
              fg "#C8C093"
              bg "#181616"
              black "#282727"
              red "#c4746e"
              green "#8a9a7b"
              yellow "#c4b28a"
              blue "#8ba4b0"
              magenta "#a292a3"
              cyan "#8ea4a2"
              white "#C8C093"
              orange "#FFA066"
          }
          neovim {
            fg "#9b9fa3"
            bg "#2e2c2f"
            black "#000000"
            red "#de6e7c"
            green "#60bff0"
            yellow "#d68c67"
            blue "#3c89b0"
            magenta "#b798e6"
            cyan "#65b8c1"
            white "#fcfff6"
            orange "#d68c67"
          }
      }

      theme "kanagawa_dragon"
      default_mode "normal"
      copy_command "pbcopy"
      default_shell "fish"
      copy_clipboard "system"
      copy_on_select true
      styled_underlines true
      show_startup_tips false
    '';
    "zellij/layouts/default.kdl".text = ''
      layout {
        default_tab_template {
          pane {
            cwd "${config.home.homeDirectory}"
          }
          pane size=1 borderless=true {
              plugin location="file:${pkgs.zjstatus}/bin/zjstatus.wasm" {
                  color_bg_dark "#1a1b26"
                  color_bg "#24283b"
                  color_bg_highlight "#292e42"
                  color_terminal_black "#414868"
                  color_fg "#c0caf5"
                  color_fg_dark "#a9b1d6"
                  color_fg_gutter "#3b4261"
                  color_dark3 "#545c7e"
                  color_comment "#565f89"
                  color_dark5 "#737aa2"
                  color_blue0 "#3d59a1"
                  color_blue "#7aa2f7"
                  color_cyan "#7dcfff"
                  color_blue1 "#2ac3de"
                  color_blue2 "#0db9d7"
                  color_blue5 "#89ddff"
                  color_blue6 "#b4f9f8"
                  color_blue7 "#394b70"
                  color_magenta "#bb9af7"
                  color_magenta2 "#ff007c"
                  color_purple "#9d7cd8"
                  color_orange "#ff9e64"
                  color_yellow "#e0af68"
                  color_green "#9ece6a"
                  color_green1 "#73daca"
                  color_green2 "#41a6b5"
                  color_teal "#1abc9c"
                  color_red "#f7768e"
                  color_red1 "#db4b4b"

                  format_left   "#[bg=$bg]{tabs}"
                  format_center "{notifications}"
                  format_right  "{mode}${
                    if isServer then "#[bg=$green,fg=$bg]  mat@nixos-server " else ""
                  }#[bg=$bg]"
                  format_space  "#[bg=$bg]"
                  format_hide_on_overlength "true"
                  format_precedence "lrc"

                  border_enabled  "false"
                  border_char     "─"
                  border_format   "#[bg=$bg]{char}"
                  border_position "top"

                  mode_normal        "#[bg=$green,fg=$bg,bold]   #[bg=$bg,fg=$green]"
                  mode_tmux          "#[bg=$purple,fg=$bg,bold]   #[bg=$bg,fg=$purple]"
                  mode_locked        "#[bg=$red,fg=$bg,bold]    #[bg=$bg,fg=$red]"
                  mode_pane          "#[bg=$cyan,fg=$bg,bold]   #[bg=$bg,fg=$cyan]"
                  mode_tab           "#[bg=$cyan,fg=$bg,bold] 󰓩  #[bg=$bg,fg=$cyan]"
                  mode_scroll        "#[bg=$orange,fg=$bg,bold] 󱕒  #[bg=$bg,fg=$orange]"
                  mode_enter_search  "#[bg=$orange,fg=$bg,bold]   #[bg=$bg,fg=$orange]"
                  mode_search        "#[bg=$orange,fg=$bg,bold]   #[bg=$bg,fg=$orange]"
                  mode_resize        "#[bg=$yellow,fg=$bg,bold] 󰙖  #[bg=$bg,fg=$yellow]"
                  mode_rename_tab    "#[bg=$yellow,fg=$bg,bold]    #[bg=$bg,fg=$yellow]"
                  mode_rename_pane   "#[bg=$yellow,fg=$bg,bold]    #[bg=$bg,fg=$yellow]"
                  mode_move          "#[bg=$yellow,fg=$bg,bold]   #[bg=$bg,fg=$yellow]"
                  mode_session       "#[bg=$magenta,fg=$bg,bold]   #[bg=$bg,fg=$magenta]"
                  mode_prompt        "#[bg=$magenta,fg=$bg,bold] 󰟶  #[bg=$bg,fg=$magenta]"

                  tab_normal              "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{floating_indicator} #[bg=$bg,fg=$comment]"
                  tab_normal_fullscreen   "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{fullscreen_indicator} #[bg=$bg,fg=$comment]"
                  tab_normal_sync         "#[bg=$terminal_black,fg=$fg_dark,bold] {index} {name}{sync_indicator} #[bg=$bg,fg=$comment]"
                  tab_active              "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{floating_indicator} #[bg=$bg,fg=$comment]"
                  tab_active_fullscreen   "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{fullscreen_indicator} #[bg=$bg,fg=$comment]"
                  tab_active_sync         "#[bg=$bg_dark,fg=$blue,bold] {index} {name}{sync_indicator} #[bg=$bg,fg=$comment]"
                  tab_separator           "#[bg=$bg] "

                  tab_sync_indicator       " "
                  tab_fullscreen_indicator " 󰊓 "
                  tab_floating_indicator   " 󰹙 "

                  notification_format_unread "#[bg=$bg,fg=$yellow]#[bg=$yellow,fg=$bg_dark] #[bg=$bg_highlight,fg=$yellow] {message}#[bg=$bg,fg=$yellow]"
                  notification_format_no_notifications ""
                  notification_show_interval "10"
              }
          }
        }
      }
    '';
  };
}
