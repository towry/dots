# https://nixos.org/manual/nixpkgs/stable/
{
  pkgs,
  lib,
  username,
  ...
}: let
  locals.packages = with pkgs;
    [
      ## Nix
      cachix
      # nix formatter
      alejandra
      nixd
      nix-health
      # git-fuzzy
      zig
      zls
      # vim-zellij-navigator
      path-git-format
      uclanr
      nix-prefetch-github
      nerd-font-patcher
      (nerdfonts.override {
        fonts = [
          "Iosevka"
          "JetBrainsMono"
        ];
      })
      # utils
      ## man page tldr
      tlrc
      sd
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
    ];
in {
  nixpkgs = {
    config = {
      # obsidian for example have unfree license.
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  home = {
    enableNixpkgsReleaseCheck = false;
    # https://github.com/nix-community/home-manager/blob/e3ad5108f54177e6520535768ddbf1e6af54b59d/modules/home-environment.nix#L184
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "${username}";
    homeDirectory =
      if pkgs.stdenv.isLinux
      then "/home/${username}"
      else "/Users/${username}";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.
    packages = locals.packages;
    # The home.packages option allows you to install Nix packages into your
    # environment.
    # home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    # ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/towry/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      EDITOR = "nvim";
    };
    sessionPath = [
      # "$HOME/.local/bin"
    ];
  };

  imports = [
    ./hm/shared.nix
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
    ./hm/kitty.nix
    ./hm/zellij.nix
    ./hm/rust.nix
    ./hm/skhd.nix
    ./hm/yabai.nix
    ./hm/dark-mode-notify.nix
  ];

  # Let Home Manager install and manage itself.
  programs = {
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
