{
  pkgs,
  config,
  lib,
  ...
}:
let
  recipesDir = ../../../conf/llm/goose/goose-recipes;

  # Manually list recipe files (more reliable than builtins.readDir)
  recipeFiles = [
    {
      name = "oracle.yaml";
      path = recipesDir + "/oracle.yaml";
      relativePath = "oracle.yaml";
      variables = {
        BRIGHTDATA_API_KEY = pkgs.nix-priv.keys.brightdata.apiKey;
      };
    }
    {
      name = "sage.yaml";
      path = recipesDir + "/sage.yaml";
      relativePath = "sage.yaml";
    }
  ];

  # Generate configFile entries for each recipe file
  recipeConfigFiles = lib.listToAttrs (map (file: {
    name = "goose/recipes/${file.relativePath}";
    value = {
      source = if lib.hasAttr "variables" file && (lib.attrNames file.variables) != []
        then pkgs.replaceVars file.path file.variables
        else file.path;
    };
  }) recipeFiles);

in
{
  home.sessionVariables = {
    GOOSE_RECIPE_PATH = "${config.xdg.configHome}/goose/recipes";
  };
  home.activation = {
    setupGooseConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cat ${config.xdg.configHome}/goose/config-source.yaml > ${config.xdg.configHome}/goose/config.yaml
      chmod u+w ${config.xdg.configHome}/goose/config.yaml
      echo "goose config setup done"
    '';
  };

  xdg.configFile = recipeConfigFiles // {
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
  };


}
