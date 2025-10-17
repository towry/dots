{
  pkgs,
  config,
  ...
}:

let
  aichatConfigDir =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/aichat"
    else
      "${config.home.homeDirectory}/.config/aichat";
in
{
  home.packages = with pkgs; [
    aichat
    # ollama
    github-mcp-server
    # mcp-proxy
  ];

  programs.fish = {
    shellAliases = { };
    functions = { };
  };

  # xdg.configFile configurations moved to specific modules

  home.file = {
    "kilocode-rule" = {
      target = "${config.home.homeDirectory}/.kilocode/rules/agents.md";
      source = ../../../conf/llm/docs/coding-rules.md;
    };
    "${aichatConfigDir}/roles" = {
      # link to ../../../conf/llm/aichat/roles dir
      source = ../../../conf/llm/aichat/roles;
      recursive = true;
    };
    "${aichatConfigDir}/config.yaml" = {
      source = pkgs.replaceVars ../../../conf/llm/aichat/config.yaml {
        DEEPSEEK_API_KEY = pkgs.nix-priv.keys.deepseek.apiKey;
        OPENROUTER_API_KEY = pkgs.nix-priv.keys.openrouter.apiKey;
        ZHIPU_API_KEY = pkgs.nix-priv.keys.zai.apiKey;
        MOONSHOT_API_KEY = pkgs.nix-priv.keys.moonshot.apiKey;
      };
    };
  };
}
