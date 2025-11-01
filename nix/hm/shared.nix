{
  pkgs,
  config,
  lib,
  theme,
  # inputs,
  ...
}:
let
  # python3 = import ../lib/python3.nix { inherit pkgs; };
  proxyConfig = import ../lib/proxy.nix { inherit lib; };
in
{
  home.sessionVariables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_AUTO_UPDATE = "1";
    NO_PROXY = proxyConfig.noProxyString;
  };
  home.activation = {
    ensureWorkspaceDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${config.home.homeDirectory}/workspace
      run mkdir -p ${config.home.homeDirectory}/.local/bin
      run mkdir -p ${config.home.homeDirectory}/Pictures/Screenshots
    '';
  };
  home.packages =
    (with pkgs; [
      ## code counter
      scc
      argc
      # bore-cli
      # termshark
      # inetutils
      rsync
      moreutils
      watchman
      # skim
      ## image support in terminal
      viu
      # concurrently
      overmind
      tig
      neovim-remote
      wget
      just
      watchexec
      # ocaml
      # dune_3
      # opam
      # ocamlPackages.ocamlformat
      # ocamlPackages.utop
      # ocamlPackages.ocaml-lsp
      # harper
      pre-commit
      ## kill process by port
      killport
    ])
    ++ [
      # python3
    ];
  xdg.configFile = {
    tig = {
      enable = true;
      source = ../../conf/tig;
      recursive = true;
    };
    yazi = {
      enable = true;
      source = ../../conf/yazi;
      recursive = true;
    };
    yabai = {
      enable = true;
      source = ../../conf/yabai;
    };
    karabiner = {
      enable = false;
      recursive = true;
      source = ../../conf/karabiner;
    };
    ghostty = {
      enable = true;
      recursive = true;
      source = ../../conf/ghostty;
    };
  };
  home.file = {
    ".config/bat/themes/" = {
      source = ../../conf/bat/themes;
      recursive = true;
    };
    ".ignore".source = ../../conf/.ignore;
    ".ripgreprc".source = ../../conf/.ripgreprc;
    "yank-file" = {
      target = ".local/bin/yank-file";
      source = ../../conf/bash/scripts/yank-file;
      executable = true;
    };
  };
  programs = {
    carapace = {
      enable = false;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    bash = {
      enable = true;
      initExtra = ''
        # tail with bat
        batail() {
          tail -f $@ | ${pkgs.bat}/bin/bat --paging=never -l log
        }
      '';
      bashrcExtra = ''
        # export PATH="$HOME/.nimble/bin:$PATH"
      '';
    };
    atuin = {
      enable = false;
      enableFishIntegration = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        auto_sync = true;
        sync_frequency = "10m";
        style = "auto";
        invert = true;
        show_preview = true;
        history_format = "{time}\t{command}\t{duration}";
        enter_accept = false;
        ignored_commands = [
          "cd"
          "ls"
          "vi"
          "cls"
          "clear"
        ];
        keys = {
          scroll_exits = false;
        };
        sync.records = true;
      };
    };
    zoxide = {
      enable = true;
    };
    yazi.enable = true;
    bottom.enable = true;
    bat = {
      package = pkgs.writeShellScriptBin "bat" ''
        if [[ "$1" == "cache" ]]; then
          command ${pkgs.bat}/bin/bat "$@"
          exit 0
        fi
        if [[ "$DARKMODE" == "dark" ]]; then
          command ${pkgs.bat}/bin/bat --theme ${theme.bat.dark} "$@"
        else
          command ${pkgs.bat}/bin/bat --theme ${theme.bat.light} "$@"
        fi
      '';
      enable = true;
      config.theme = "${theme.bat.dark}";
    };
    jq.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    eza = {
      enable = true;
      icons = "auto";
      enableFishIntegration = false;  # Was: true
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          serverAliveInterval = 240;
        };
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
      includes = [
        "config.d/*"
      ];
    };
  };
}
