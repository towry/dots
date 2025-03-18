{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    raycast
    # vscode
    # logseq
    # brave
    ice-bar
    net-news-wire
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
