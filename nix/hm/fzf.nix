{
  pkgs,
  lib,
  ...
}: let
  key-bindings = [
    {
      # ctrl+o
      lhs = "\\co";
      rhs = "fzf-file-widget-wrapped";
    }
  ];
in {
  home.sessionVariables = {
    FZF_COMPLETION_OPTS = "--border --info=inline";
  };
  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --color=always -td --ignore-file=$HOME/.ignore";
    defaultOptions = [
      "--ansi"
      # nightfox
      "--color=fg:#cdcecf,bg:#131a24,hl:#5f87af --color=fg+:#d60d7b,bg+:#3a5275,hl+:#5fd7ff --color=info:#afaf87,prompt:#c74462,pointer:#bf1537 --color=marker:#ffff00,spinner:#af5fff,header:#db3e1f"
      # nord
      # "--color=fg:#cdcecf,fg+:#d0d0d0,bg:#232831,bg+:#3b4252 --color=hl:#8aa872,hl+:#a3be8c,info:#afaf87,marker:#8aa872 --color=prompt:#a54e56,spinner:#a96ca5,pointer:#d092ce,header:#93ccdc --color=border:#5c6781,label:#bbc3d4,query:#d9d9d9"
      # "--no-border"
      "--border=sharp"
      "--reverse"
      "--preview-window=sharp"
      # "--preview-window=border-left"
      # this keybind should match the telescope ones in nvim config
      ''--bind="ctrl-u:unix-line-discard+top,tab:down,shift-tab:up,ctrl-d:preview-down,ctrl-f:preview-up"''
    ];
    fileWidgetCommand = "${pkgs.ripgrep}/bin/rg --files";
    fileWidgetOptions = [
      "--keep-right"
      # Preview files with bat
      "--preview '${pkgs.bat}/bin/bat --color=always {}'"
    ];
  };
  programs.fish = {
    plugins = [
      {
        name = "fzf";
        src = pkgs.fetchFromGitHub {
          owner = "PatrickF1";
          repo = "fzf.fish";
          rev = "8920367cf85eee5218cc25a11e209d46e2591e7a";
          sha256 = "sha256-T8KYLA/r/gOKvAivKRoeqIwE2pINlxFQtZJHpOy9GMM";
        };
      }
    ];
    interactiveShellInit = ''
      for mode in insert default normal
      ${lib.concatMapStrings (keybind: ''
          bind -M $mode ${keybind.lhs} ${keybind.rhs}
        '')
        key-bindings}
      end

      set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"
    '';
    functions = {
      fzf-file-widget-wrapped = ''
        fzf-file-widget
        # _prompt_move_to_bottom
      '';
    };
  };
}
