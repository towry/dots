{
  pkgs,
  username,
  vars,
  ...
}: {
  imports = [];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  environment = {
    variables = {
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    systemPackages = with pkgs; [
      # eza # Ls
      # git # Version Control
      # tldr # Help
    ];
  };

  programs.fish.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = false;
      cleanup = "zap";
    };
    casks = [
      "aldente"
      "appcleaner"
      "raycast"
      "postico"
    ];
    masApps = {
    };
  };

  home-manager.users.${username} = {
    imports = [
      ../../home.nix
    ];
  };

  services.nix-daemon.enable = true;

  nix = {
    settings = {
      substituters = [
        "https://dots.cachix.org"
        "https://nix-community.cachix.org"
        "https://towry.cachix.org"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      trusted-users = [
        "root"
        "@staff"
        username
      ];
      trusted-public-keys = [
        "dots.cachix.org-1:H/gV3a5Ossrd/R+qrqrAk9tr3j51NHEB+pCTOk0OjYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "towry.cachix.org-1:7wS4ROZkLQMG6TZPt4K6kSwzbRJZf6OiyR9tWgUg3hY="
      ];
    };
    package = pkgs.nix;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {
    stateVersion = 4;
  };
}
