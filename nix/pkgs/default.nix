{
  inputs,
  pkgs,
  system,
  ...
}:
{
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
}
