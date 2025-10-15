{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs.helix = {
    enable = true;
    defaultEditor = config.vars.editor == "helix";

    # lsp servers
    languages.language-server = {
      typos = {
        # typos-lsp
        command = "${lib.getExe pkgs.typos-lsp}";
      };
    };

    # lsp languages
    languages.language = [
      {
        name = "typescript";
        language-servers = [
          "typescript-language-server"
          "typos"
        ];
        formatter.command = "prettier";
        formatter.args = [
          "--parser"
          "typescript"
        ];
        formatter.binary = "${lib.getExe pkgs.nodePackages.prettier}";
      }
      {
        name = "python";
        language-servers = [ "typos" ];
        formatter.command = "ruff";
        formatter.args = [
          "format"
          "--line-length"
          "88"
          "-"
        ];
        formatter.binary = "${lib.getExe pkgs.ruff}";
      }
      {
        name = "nix";
        language-servers = [
          "nil"
          "typos"
        ];
        formatter.binary = "${lib.getExe pkgs.nixfmt-classic}";
        formatter.command = "nixfmt";
      }
      # markdown
      {
        name = "markdown";
        language-servers = [ "typos" ];
      }
    ];

    settings = {
      theme = "base16_default";
      editor.color-modes = true;
      editor.rulers = [ 80 ];
      editor.auto-save = true;
      editor.auto-format = true;

      editor.lsp.enable = true;
      editor.lsp.display-messages = true;
      editor.lsp.display-inlay-hints = false;

      editor.cursor-shape.insert = "bar";

      editor.statusline = {
        left = [
          "mode"
          "spinner"
          "version-control"
        ];
        center = [
          "file-name"
          "file-modification-indicator"
        ];
        right = [
          "diagnostics"
          "selections"
          "position"
          "file-encoding"
          "file-line-ending"
          "file-type"
        ];
        separator = "│";
        mode.normal = "NORMAL";
        mode.insert = "INSERT";
        mode.select = "SELECT";
      };

      keys.normal = {
        H = [ "goto_line_start" ];
        L = [ "goto_line_end" ];
        G = [ "goto_last_line" ];
        y = [
          "yank"
          ":clipboard-yank"
        ];
        ";" = [ "command_mode" ];
      };
      keys.insert.j = {
        j = [ "normal_mode" ];
      };
    };

    # LSPs and formatters installed globally for convenience
    extraPackages = with pkgs; [
      # Markdown
      # markdown-oxide
      marksman

      # TS/JS
      nodePackages.typescript-language-server
      nodePackages.prettier

      # Nix
      nixfmt-classic
    ];
  };
}
