{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    raycast
    # vscode
    logseq
    # brave
    ice-bar
  ];

  homebrew = {
    casks = [
      "postico"
      "spaceid"
      "telegram-desktop"
    ];
    masApps = {
    };
  };
}
