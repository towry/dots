{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    raycast
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
      "block-goose-cli"
    ];
    casks = [
      # "font-maple-mono"
      "postico"
      # "spaceid"
      "telegram-desktop"
    ];
    masApps = {
    };
  };
}
