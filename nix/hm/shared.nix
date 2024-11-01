{
  pkgs,
  config,
  lib,
  theme,
  # inputs,
  ...
}: let
  python3 = import ../lib/python3.nix {inherit pkgs;};
in {
  home.sessionVariables = {
    GOPATH = "$HOME/workspace/goenv";
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_AUTO_UPDATE = "1";
  };
  home.activation = {
    ensureWorkspaceDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ${config.home.homeDirectory}/workspace
      run mkdir -p ${config.home.homeDirectory}/workspace/goenv
    '';
  };
  # TODO: move to module.
  programs.fish.shellInit = ''
    if ! set -q ASDF_DIR
      set -x ASDF_DIR ${pkgs.asdf-vm}/share/asdf-vm
    end
  '';
  home.packages =
    (with pkgs; [
      ## code counter
      scc
      # bore-cli
      # termshark
      # inetutils
      moreutils
      # concurrently
      overmind
      tig
      neovim-remote
      wget
      just
      watchexec
      ocaml
      dune_3
      # opam
      # ocamlPackages.ocamlformat
      # ocamlPackages.utop
      # ocamlPackages.ocaml-lsp
      asdf-vm
      docker-credential-helpers
      uv
    ])
    ++ [
      python3
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
  };
  home.file = {
    ".tool-versions".source = ../../conf/asdf/tool-versions;
    ".config/bat/themes/" = {
      source = ../../conf/bat/themes;
      recursive = true;
    };
    ".ignore".source = ../../conf/.ignore;
    ".ripgreprc".source = ../../conf/.ripgreprc;
  };
  programs = {
    jujutsu = {
      enable = false;
      settings = {
        ui = {
          default-command = "log";
        };
        user = {
          email = "towry@users.noreply.github.com";
          name = "Towry Wang";
        };
      };
    };
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
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi

        export PATH="$HOME/.nimble/bin:$PATH"
      '';
    };
    atuin = {
      enable = true;
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
        ignored_commands = ["cd" "ls" "vi" "cls" "clear"];
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
    eza.enable = true;
    ssh = {
      enable = true;
      serverAliveInterval = 240;
      matchBlocks = {
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
      includes = [
        "config.d/*"
      ];
    };
    poetry = {
      # https://python-poetry.org/docs/configuration/
      enable = false;
      settings = {
        # need make sure no local .venv or {cache-dir}/virtualenvs exists
        virtualenvs.create = false;
        virtualenvs.in-project = true;
      };
    };
  };
}
