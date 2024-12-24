{ ... }:
{
  # docs: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          selectedLineBgColor = [
            "reverse"
          ];
        };
        mouseEvents = true;
        showFileTree = false;
        commitHashLength = 6;
        showDivergenceFromBaseBranch = "arrowAndNumber";
        nerdFontsVersion = "3";
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
          pager = "delta --dark --paging=never";
          externalDiffCommand = "difft --color=always";
        };
      };
      update = {
        method = "never";
      };
      os = {
        edit = "nvim";
        editAtLine = "{{editor}} +{{line}} {{filename}}";
      };
      # https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md
      customCommands = [
        {
          key = "H";
          context = "commits";
          command = "gh browse {{.SelectedLocalCommit.Hash}}";
        }
      ];
      quitOnTopLevelReturn = true;
      disableStartupPopups = true;
      promptToReturnFromSubprocess = true;
      notARepository = "skip";
    };
  };
}
