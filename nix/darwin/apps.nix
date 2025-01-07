{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    raycast
    vscode
    logseq
    # brave
    ice-bar
    man-pages
    man-pages-posix
    groff
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
