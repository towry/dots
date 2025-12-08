{
  pkgs,
  username,
  config,
  system,
  ...
}:
{
  imports = [
    ../modules/config.nix
    ./vars.nix
    ./apps.nix
    ./yabai.nix
    # ./autoraise.nix
    # ./jankyborders.nix
  ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  nixpkgs = {
    hostPlatform = system;
    config = {
      allowUnfree = true;
      # Disable tests during builds to avoid test failures blocking installation
      doCheck = false;
      doInstallCheck = false;
    };
  };
  environment = {
    variables = {
      EDITOR = "${config.vars.editor}";
      VISUAL = "${config.vars.editor}";
      # build env
    };
    shells = [
      pkgs.bashInteractive
      pkgs.fish
    ];
    pathsToLink = [
      "/include"
      "/lib"
    ];
    # extraOutputsToInstall = [
    #   "out"
    #   "lib"
    #   "bin"
    #   "dev"
    # ];
    systemPath = [
      config.homebrew.brewPrefix
    ];
  };

  programs.fish.enable = true;
  programs.fish.package = pkgs.fish;

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = false;
      cleanup = "zap";
    };
  };

  home-manager.users.${username} = {
    imports = [
      ../home.nix
    ];
  };

  nix = {
    settings = {
      # for nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      # --
      substituters = [
        "https://dots.cachix.org"
        "https://nix-community.cachix.org"
        "https://towry.cachix.org"
        # "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-users = [
        "${username}"
      ];
      trusted-public-keys = [
        "dots.cachix.org-1:H/gV3a5Ossrd/R+qrqrAk9tr3j51NHEB+pCTOk0OjYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "towry.cachix.org-1:7wS4ROZkLQMG6TZPt4K6kSwzbRJZf6OiyR9tWgUg3hY="
      ];
    };
    # package = pkgs.nix;
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {
    primaryUser = username;
    stateVersion = 6;

    defaults = {
      screencapture.location = "~/Pictures/Screenshots";
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
      };
    };
  };
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };
}
