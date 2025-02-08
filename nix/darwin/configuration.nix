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
    # ./jankyborders.nix
  ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  nixpkgs.hostPlatform = system;

  environment = {
    variables = {
      EDITOR = "${config.vars.editor}";
      VISUAL = "${config.vars.editor}";
      # build env
      CPATH = "/etc/profiles/per-user/${username}/include";
      CMAKE_INCLUDE_PATH = "/etc/profiles/per-user/${username}/include";
      CMAKE_LIBRARY_PATH = "/etc/profiles/per-user/${username}/lib";
      C_INCLUDE_PATH = "/etc/profiles/per-user/${username}/include";
      CPLUS_INCLUDE_PATH = "/etc/profiles/per-user/${username}/include";
      LDFLAGS = "-L/etc/profiles/per-user/${username}/lib";
      CFLAGS = "-I/etc/profiles/per-user/${username}/include";
      CPPFLAGS = "-I/etc/profiles/per-user/${username}/include";
      LD_LIBRARY_PATH = "/etc/profiles/per-user/${username}/lib";
      DYLD_LIBRARY_PATH = "/etc/profiles/per-user/${username}/lib";
      LIBS = "-L/etc/profiles/per-user/${username}/lib -Wl,-rpath,/etc/profiles/per-user/${username}/lib";
      PKG_CONFIG_PATH = "/etc/profiles/per-user/${username}/lib/pkgconfig";
      DYLD_FALLBACK_LIBRARY_PATH = "/etc/profiles/per-user/${username}/lib";
    };
    shells = [
      pkgs.bashInteractive
      pkgs.fish
    ];
    pathsToLink = [
      "/include"
      "/lib"
    ];
    extraOutputsToInstall = [
      "out"
      "lib"
      "bin"
      "dev"
    ];
    systemPath = [
      config.homebrew.brewPrefix
    ];
  };

  programs.fish.enable = true;

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

  services.nix-daemon.enable = true;

  nix = {
    settings = {
      # for nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      sandbox = "relaxed";
      # --
      substituters = [
        "https://dots.cachix.org"
        "https://nix-community.cachix.org"
        "https://towry.cachix.org"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
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
    package = pkgs.nix;
    optimise = {
      automatic = true;
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {
    stateVersion = 4;

    defaults = {
      screencapture.location = "~/Pictures/Screenshots";
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
      };
    };
  };
  documentation.enable = true;
  programs.info.enable = true;
  programs.man.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
}
