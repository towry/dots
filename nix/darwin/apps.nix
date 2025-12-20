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
      "questdb"
      # "rift"
      # "html2markdown"
    ];
    casks = [
      "bruno"
      # "amethyst"
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
