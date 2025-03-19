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
      "font-maple-mono"
      "postico"
      "spaceid"
      "telegram-desktop"
    ];
    masApps = {
    };
  };
}
