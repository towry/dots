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
    brews = [
      "asdf"
      "codex"
      # "html2markdown"
      # "block-goose-cli"
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
