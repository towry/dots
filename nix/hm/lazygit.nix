{ pkgs-stable, ... }:
{
  # docs: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit = {
    package = pkgs-stable.lazygit;
    enable = true;
    settings = {
      gui = {
        theme = {
          selectedLineBgColor = [
            "#343A51"
          ];
          selectedRangeBgColor = [
            "#343A51"
          ];
        };
        mouseEvents = true;
        showFileTree = true;
        commitHashLength = 6;
        showDivergenceFromBaseBranch = "arrowAndNumber";
        enlargedSideViewLocation = "top";
        showBottomLine = false;
        commandLogSize = 4;
        expandFocusedSidePanel = true;
        nerdFontsVersion = "3";
        windowSize = "half"; # "full" | "half" | "default"
        border = "single";
        animateExplosion = false;
        portraitMode = "auto"; # "never" | "always" | "auto"
        filterMode = "fuzzy"; # "fuzzy" | "substring(default)"
        statusPanelView = "dashboard"; # "dashboard" | "allBranchesLog"
      };
      git = {
        merging = {
          args = "--no-ff";
        };
        skipHookPrefix = "WIP";
        autoFetch = true;
        autoRefresh = true;
        fetchAll = false;
        paging = {
          colorArg = "always";
          externalDiffCommand = "difft --color=always";
        };
      };
      update = {
        method = "never";
      };
      os = {
        edit = "nvim";
        editPreset = "nvim-remote";
        editAtLine = "nvim +{{line}} {{filename}}";
      };
      # https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md
      customCommands = [
        {
          key = "H";
          context = "commits";
          command = "gh browse {{.SelectedCommit.Sha}}";
        }
        # in diff view, open file in nvim at selected commit
        {
          key = "E";
          context = "commitFiles";
          command = "nvim -c 'Gedit {{.SelectedCommit.Sha}}:{{.SelectedFile.Name}}'";
        }
      ];
      quitOnTopLevelReturn = false;
      disableStartupPopups = true;
      promptToReturnFromSubprocess = false;
      notARepository = "quit";
      keybinding = {
        universal = {
          quit = "<c-q>";
          quitWithoutChangingDirectory = "Q";
        };
      };
    };
  };
}
