{ pkgs, ... }:

{
  home.packages = [ pkgs.gopls ];

  programs = {
    go.enable = true;
  };
}
