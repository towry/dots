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
      "--color=bg+:#2d4f67"
      "--height=60%"
      "--no-border"
      "--reverse"
      "--preview-window=border-left"
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
