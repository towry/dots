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
      plugins {
          tab-bar location="zellij:tab-bar"
          status-bar location="zellij:status-bar"
          strider location="zellij:strider"
          compact-bar location="zellij:compact-bar"
          session-manager location="zellij:session-manager"
          configuration location="zellij:configuration"
          plugin-manager location="zellij:plugin-manager"
          about location="zellij:about"
      }
      load_plugins {
      }

      ///======
      /// Keybinds
      /// 1. Put all functional keybind in the tmux mode.
      ///======

      keybinds {
          unbind "Ctrl g"
          unbind "Ctrl q"

          normal {
              bind "Super [" { GoToPreviousTab; }
              bind "Super ]" { GoToNextTab; }
              bind "Super 1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "Super 2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "Super 3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "Super 4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "Super 5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "Super 6" { GoToTab 6; SwitchToMode "Normal"; }
              bind "Super 7" { GoToTab 7; SwitchToMode "Normal"; }
              bind "Super 8" { GoToTab 8; SwitchToMode "Normal"; }
              bind "Super 9" { GoToTab 9; SwitchToMode "Normal"; }
          }

          locked {
              bind "Super g" { SwitchToMode "Normal"; }
          }

          tab {
            // unbind default tab active sync
            unbind "s"
          }

          tmux {
              bind "Ctrl b" { DumpScreen "${config.home.homeDirectory}/workspace/zellij-buffer.txt"; SwitchToMode "Normal"; }
          }

          // ====

          shared_except "locked" {
              bind "Super g" { SwitchToMode "Locked"; }
          }
          shared_except "locked" "normal" {
              bind "Enter" "Esc" { SwitchToMode "Normal"; }
          }
          shared_except "pane" "locked" {
              unbind "Ctrl p"
              bind "Super p" { SwitchToMode "Pane"; }
          }
          shared_except "resize" "locked" {
              unbind "Ctrl n"
              bind "Super n" { SwitchToMode "Resize"; }
          }
          shared_except "scroll" "locked" {
              unbind "Ctrl s"
              bind "Super s" { SwitchToMode "Scroll"; }
          }
          shared_except "session" "locked" {
              unbind "Ctrl o"
              bind "Super o" { SwitchToMode "Session"; }
          }
          shared_except "tab" "locked" {
              unbind "Ctrl t"
              bind "Super t" { SwitchToMode "Tab"; }
          }
          shared_except "move" "locked" {
              unbind "Ctrl h"
              bind "Super k" { SwitchToMode "Move"; }
          }
          shared_except "tmux" "locked" {
              unbind "Ctrl b"
              bind "Ctrl z" { SwitchToMode "Tmux"; }
          }
      }

      ui {
          pane_frames {
              hide_session_name false
              rounded_corners false
          }
      }

      themes {
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
      }

      theme "kanagawa_wave"
      default_mode "normal"
      copy_command "pbcopy"
      default_shell "fish"
      copy_clipboard "system"
      support_kitty_keyboard_protocol true
      copy_on_select true
      show_release_notes false
      styled_underlines true
      show_startup_tips true
    '';
  };
}
