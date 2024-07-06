{
  pkgs,
  config,
  lib,
  ...
}: {
  home.sessionVariables = {
    GOPATH = "$HOME/workspace/goenv";
    HOMEBREW_NO_ANALYTICS = "1";
  };
  home.activation = {
    ensureWorkspaceDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ${config.home.homeDirectory}/workspace
      run mkdir -p ${config.home.homeDirectory}/workspace/goenv
    '';
  };
  home.packages = with pkgs; [
    tig
    python311Packages.pynvim
    neovim-remote
    wget
    just
    watchexec
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
    ".config/bat/themes/kanagawa-dragon.tmTheme".source = ../../conf/kanagawa-dragon.tmTheme;
    ".ignore".source = ../../conf/.ignore;
    ".ripgreprc".source = ../../conf/.ripgreprc;
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
        if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
          . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
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
      enable = true;
      config.theme = "kanagawa-dragon";
    };
    jq.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    eza.enable = true;
    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "ssh.github.com";
          port = 443;
        };
      };
    };
    pyenv = {
      enable = true;
      rootDirectory = "${config.home.homeDirectory}/.pyenv";
    };
    poetry = {
      # https://python-poetry.org/docs/configuration/
      enable = true;
      settings = {
        virtualenvs.create = true;
        virtualenvs.in-project = true;
      };
    };
  };
}
