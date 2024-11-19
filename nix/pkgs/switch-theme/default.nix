{pkgs, ...}: let
  python = import ../../lib/python3.nix {inherit pkgs;};
in
  pkgs.writeShellApplication {
    name = "switch-theme";
    runtimeInputs = with pkgs; [coreutils neovim-remote python];
    text =
      if pkgs.system == "aarch64-darwin"
      then ''
        #!${pkgs.bash}/bin/bash

        export PATH="$PATH:${pkgs.neovim-remote}/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin"

        ${pkgs.dark-notify}/bin/dark-mode-notify -c "PATH=$PATH:${pkgs.neovim-remote}/bin ${python}/bin/python3 ${./switch-theme.py}" 2>&1
      ''
      else ''
        #!${pkgs.bash}/bin/bash

        export PATH="$PATH:${pkgs.neovim-remote}/bin:$HOME/.nix-profile/bin:/run/current-system/sw/bin"

        ${pkgs.dark-notify}/bin/dark-notify -c "PATH=$PATH:${pkgs.neovim-remote}/bin ${python}/bin/python3 ${./switch-theme.py}" 2>&1
      '';
  }
