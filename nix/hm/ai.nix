{ pkgs, config, ... }:

let
  configDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/aichat"
    else
      "${config.home.homeDirectory}/.config/aichat";

in
{
  home.packages = with pkgs; [
    aichat
    ollama
    aider-chat
    github-mcp-server
    goose-cli
  ];

  programs.fish = {
    shellAliases = {
    };
    functions = {
      gen-task-prompt = ''
        set tmpfile (mktemp)
        $EDITOR $tmpfile
        if test -s $tmpfile
          mkdir -p llm/task-plan-prompts
          set timestamp (date +%Y%m%d_%H%M%S)
          set output_file "llm/task-plan-prompts/task_plan_$timestamp.md"
          cat $tmpfile | aichat --role gen-prompt > $output_file
          echo "Task plan generated: $output_file"
        else
          echo "No content provided, aborting."
        end
        rm $tmpfile
      '';
    };
  };

  xdg.configFile = {
    "goose/config.yaml" = {
      source = ../../conf/llm/goose/config.yaml;
    };
    "goose/.goosehint" = {
      source = ../../conf/llm/docs/coding-rules.md;
    };
  };

  home.file = {
    "${configDir}/roles" = {
      # link to ../../conf/llm/aichat/roles dir
      source = ../../conf/llm/aichat/roles;
      recursive = true;
    };
    "${configDir}/config.yaml" = {
      source = pkgs.replaceVars ../../conf/llm/aichat/config.yaml {
        DEEPSEEK_API_KEY = pkgs.nix-priv.keys.deepseek.apiKey;
      };
    };
    ".aider.conf.yml" = {
      text = builtins.toJSON {

      };
    };
  };
}
