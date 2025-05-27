# https://nixos.org/manual/nixpkgs/stable/
{
  pkgs,
  lib,
  username,
  useGlobalPkgs ? false,
  ...
}:
let
  locals.packages =
    with pkgs;
    [
      ## Nix
      cachix
      # nix formatter
      treefmt
      nixfmt-rfc-style
      nixd
      # nix-health
      # git-fuzzy
      # zig
      # zls
      # vim-zellij-navigator
      path-git-format
      uclanr
      nix-prefetch-github
      # nerd-font-patcher
      lxgw-wenkai
      # utils
      ## man page tldr
      tlrc
      sd
      difftastic
      ## image view support
      imagemagick
      luajitPackages.magick
    ]
    ++ lib.lists.optionals pkgs.stdenv.isDarwin [
      # macOs packages
      # raycast
      # libiconv # neovim build need this.
      # darwin.apple_sdk.frameworks.Security
      # darwin.apple_sdk.frameworks.Foundation
    ]
    ++ lib.lists.optionals pkgs.stdenv.isLinux [
      # linux packages
      xclip
      maple-mono
    ];
in
{
  nixpkgs = lib.mkIf (!useGlobalPkgs) {
    config = {
      # obsidian for example have unfree license.
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${username}";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/${username}" else "/Users/${username}";
    stateVersion = "24.11"; # Please read the comment before changing.
    packages = locals.packages;
    sessionVariables = {
      EDITOR = "nvim";
    };
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
      "/Applications/Ghostty.app/Contents/MacOS/"
    ];
    file = {
      bashScripts = {
        enable = true;
        source = ../conf/bash/scripts;
        target = ".local/bash/scripts";
      };
    };
  };

  imports = [
    ./hm/shared.nix
    ./hm/elixir.nix
    ./hm/buildeps.nix
    ./hm/fish.nix
    ./hm/git.nix
    ./hm/starship.nix
    ./hm/fzf.nix
    ./hm/editor.nix
    ./hm/frontend-dev.nix
    ./hm/tmux.nix
    # ./hm/alacritty.nix
    # ./hm/wezterm.nix
    # ./hm/kitty.nix
    # ./hm/zellij.nix
    ./hm/rust.nix
    # ./hm/go.nix
    # ./hm/skhd.nix
    # ./hm/yabai.nix
    ./hm/dark-mode-notify.nix
    ./hm/lazygit.nix
    ./hm/jj.nix
    # ./hm/autoraise.nix
    ./hm/ai.nix
  ];

  # Let Home Manager install and manage itself.
  programs = {
    man.enable = false;
    man.generateCaches = false;
    home-manager.enable = true;
    # Direnv integration for flakes
    direnv = {
      enable = true;
      stdlib = ''
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            local hash="$(${pkgs.coreutils}/bin/sha1sum - <<<"$PWD" | cut -c-7)"
            local path="''${PWD//[^a-zA-Z0-9]/-}"
            echo "''${XDG_CACHE_HOME:-"$HOME/.cache"}/direnv/layouts/''${hash}''${path}"
          )}"
        }
      '';
      config = {
        disable_stdin = true;
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "7s";
        hide_env_diff = true;
        whitelist = {
          prefix = [
            # "~/moseeker"
          ];
        };
      };
    };
    direnv.nix-direnv.enable = true;
    # nix-index: query local packages.
    nix-index = {
      enable = false;
      enableZshIntegration = false;
    };
  };

  fonts.fontconfig.enable = true;
}
