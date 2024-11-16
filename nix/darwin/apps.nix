{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    raycast
    vscode
    brave
  ];

  homebrew = {
    casks = [
      "postico"
      "spaceid"
      "telegram"
    ];
    masApps = {
    };
  };
}
