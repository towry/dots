{ pkgs-stable, config, ... }:
let
  bashScriptsDir = "${config.home.homeDirectory}/.local/bash/scripts";
  aichatSelectCommit = [
    {
      key = "<c-a>";
      description = "Auto commit with AI";
      command = ''
        {
          echo "Running commit suggestion..."
          aichat --role git-commit -S -c "$(${bashScriptsDir}/git-commit-context.sh)" | \
              ${bashScriptsDir}/git-commit-chunk-text.sh
        } 2>> /tmp/lazygit-debug.log
      '';
      context = "files";
      stream = true;
      loadingText = "Generating commit suggestion";
    }
  ];
  gitTownCommands = [
    {
      key = "Y";
      context = "global";
      description = "Git-Town sync";
      command = "git-town sync --all";
      stream = true;
      loadingText = "Syncing";
    }
    {
      key = "U";
      context = "global";
      description = "Git-Town Undo (undo the last git-town command)";
      command = "git-town undo";
      prompts = [
        {
          type = "confirm";
          title = "Undo Last Command";
          body = "Are you sure you want to Undo the last git-town command?";
        }
      ];
      stream = true;
      loadingText = "Undoing Git-Town Command";
    }
    {
      key = "!";
      context = "global";
      description = "Git-Town Repo (opens the repo link)";
      command = "git-town repo";
      stream = true;
      loadingText = "Opening Repo Link";
    }
    {
      key = "a";
      context = "localBranches";
      description = "Git-Town Append";
      prompts = [
        {
          type = "input";
          title = "Enter name of new child branch. Branches off of '{{.CheckedOutBranch.Name}}'";
          key = "BranchName";
        }
      ];
      command = "git-town append {{.Form.BranchName}}";
      stream = true;
      loadingText = "Appending";
    }
    {
      key = "h";
      context = "localBranches";
      description = "Git-Town Hack (creates a new branch)";
      prompts = [
        {
          type = "input";
          title = "Enter name of new branch. Branches off of 'Main'";
          key = "BranchName";
        }
      ];
      command = "git-town hack {{.Form.BranchName}}";
      stream = true;
      loadingText = "Hacking";
    }
    {
      key = "K";
      context = "localBranches";
      description = "Git-Town Delete (deletes the current feature branch and sync)";
      command = "git-town delete";
      prompts = [
        {
          type = "confirm";
          title = "Delete current feature branch";
          body = "Are you sure you want to delete the current feature branch?";
        }
      ];
      stream = true;
      loadingText = "Deleting Feature Branch";
    }
    {
      key = "p";
      context = "localBranches";
      description = "Git-Town Propose (creates a pull request)";
      command = "git-town propose";
      stream = true;
      loadingText = "Creating pull request";
    }
    {
      key = "P";
      context = "localBranches";
      description = "Git-Town Prepend (creates a branch between the current branch and its parent)";
      prompts = [
        {
          type = "input";
          title = "Enter name of the child branch between '{{.CheckedOutBranch.Name}}' and its parent";
          key = "BranchName";
        }
      ];
      command = "git-town prepend {{.Form.BranchName}}";
      stream = true;
      loadingText = "Prepending";
    }
    {
      key = "S";
      context = "localBranches";
      description = "Git-Town Skip (skip branch with merge conflicts when syncing)";
      command = "git-town skip";
      stream = true;
      loadingText = "Skipping";
    }
    {
      key = "G";
      context = "files";
      description = "Git-Town GO aka:continue (continue after resolving merge conflicts)";
      command = "git-town continue";
      stream = true;
      loadingText = "Continuing";
    }
  ];
in
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
          # colorArg = "always";
          # externalDiffCommand = "difft --color=always";
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
      customCommands =
        [
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
        ]
        ++ gitTownCommands
        ++ aichatSelectCommit;
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
