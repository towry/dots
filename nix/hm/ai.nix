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
  ];

  home.file = {
    "${configDir}/roles" = {
      # link to ../../conf/llm/aichat/roles dir
      source = ../../conf/llm/aichat/roles;
      recursive = true;
    };
    "${configDir}/config.yaml" = {
      source = pkgs.replaceVars ../../conf/llm/aichat/config.yaml {
        DEEPSEEK_API_KEY = pkgs.nix-priv.keys.deepseek.apikey;
      };
    };
    ".aider.conf.yml" = {
      text = builtins.toJSON {

      };
    };
  };
}
