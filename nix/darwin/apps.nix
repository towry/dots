{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    raycast
    vscode
    # brave
    ice-bar
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
