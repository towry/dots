{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.activation = {
    setupGooseConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat ${config.xdg.configHome}/goose/config-source.yaml > ${config.xdg.configHome}/goose/config.yaml
      chmod u+w ${config.xdg.configHome}/goose/config.yaml
      echo "goose config setup done"
      # copy the goose recipes to the goose recipes directory
      mkdir -p ${config.xdg.configHome}/goose/recipes
      cp -rf ${config.xdg.configHome}/goose/goose-recipes_/* ${config.xdg.configHome}/goose/recipes/
      echo "goose recipes copied to ${config.xdg.configHome}/goose/recipes"
    '';
  };

  xdg.configFile = {
    "goose/config-source.yaml" = {
      source = pkgs.replaceVars ../../../conf/llm/goose/config.yaml {
        GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
        BRAVE_API_KEY = pkgs.nix-priv.keys.braveSearch.apiKey;
        # ANYTYPE_API_KEY = pkgs.nix-priv.keys.anytype.apiKey;
        # STACKOVERFLOW_API_KEY = pkgs.nix-priv.keys.stackoverflow.apiKey;
        MASTERGO_TOKEN = pkgs.nix-priv.keys.mastergo.token;
      };
    };
    "goose/.goosehints" = {
      source = ../../../conf/llm/docs/coding-rules.md;
    };
    "goose/task-plan-review-prompt.md" = {
      source = ../../../conf/llm/docs/prompts/task-plan-review.md;
    };
    "goose/goose-recipes_" = {
      source = ../../../conf/llm/goose-recipes;
      recursive = true;
    };
  };

  home.file = {
    "goose-recipes" = {
      enable = true;
      target = "${config.home.homeDirectory}/workspace/goose-recipes_";
      source = ../../../conf/llm/goose-recipes;
      recursive = true;
    };
  };
}
