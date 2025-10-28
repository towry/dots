{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # vscode
    # logseq
    # brave
    # ice-bar
    net-news-wire
    # elixir
    # elixir-ls
  ];

  homebrew = {
    taps = [
      "acsandmann/tap"
    ];
    brews = [
      "asdf"
      "rift"
      # "html2markdown"
    ];
    casks = [
      "amethyst"
      "raycast"
      # "sublime-merge"
      # "font-maple-mono"
      "postico"
      # "spaceid"
      "telegram-desktop"
    ];
    masApps = {
    };
  };
}
