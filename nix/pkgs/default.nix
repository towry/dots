{
  inputs,
  pkgs,
  system,
  ...
}:
{
  zjstatus = inputs.zjstatus.packages.${system}.default;
  vim-zellij-navigator = pkgs.callPackage ./vim-zellij-navigator.nix { };
}
