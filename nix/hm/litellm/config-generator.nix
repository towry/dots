# Shared LiteLLM config generator
# Used by both home-manager module and CI/CD builds
{ pkgs, lib }:

let
  proxyConfig = import ../../lib/proxy.nix { inherit lib pkgs; };

  # Import model token limits module
  tokenModule = import ./model-tokens.nix { inherit lib; };
  inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;

  # Import general models
  generalModels = import ./general-models.nix {
    inherit pkgs;
    inherit (tokenModule) getMaxInputTokens getMaxOutputTokens getMaxTokens;
  };

  # Import model group modules
  benderMuffinModels = import ./bender-muffin.nix {
    inherit pkgs;
  };

  freeMuffinModels = import ./free-muffin.nix {
    inherit pkgs;
  };

  frontierMuffinModels = import ./frontier-muffin.nix {
    inherit pkgs;
  };

  # Combine all models
  modelList = generalModels ++ benderMuffinModels ++ freeMuffinModels ++ frontierMuffinModels;

in
{
  # Export model list
  inherit modelList;

  # Generate the complete config
  config = {
    model_list = modelList;
    litellm_settings = {
      REPEATED_STREAMING_CHUNK_LIMIT = 100;
      image_generation_model = "openrouter/x-ai/grok-4-fast";
      master_key = "os.environ/LITELLM_MASTER_KEY";
      request_timeout = 600;
      num_retries = 2;
      allowed_fails = 3;
      cooldown_time = 30;
      drop_params = true;
      json_logs = false;
      turn_off_message_logging = true;
      fallbacks = [
        { "copilot/claude-haiku-4.5" = [ "opencodeai/claude-haiku-4-5" ]; }
        { "copilot/claude-sonnet-4.5" = [ "opencodeai/claude-sonnet-4.5" ]; }
        { "copilot/gpt-5-mini" = [ "openrouter/minimax/minimax-m2" ]; }
        { "frontier-muffin" = [ "packy/claude-sonnet-4-5" ]; }
        { "bender-muffin" = [ "packy/claude-haiku-4-5" ]; }
      ];
      cache = false;
      cache_params = {
        namespace = "litellm.caching.caching";
        type = "redis";
        host = "${pkgs.nix-priv.keys.litellm.redisHost}";
        port = pkgs.nix-priv.keys.litellm.redisPort;
        password = "${pkgs.nix-priv.keys.litellm.redisPass}";
        ttl = 3600;
        socket_timeout = 20;
        socket_connect_timeout = 20;
      };
      disable_copilot_system_to_assistant = true;
      enable_json_schema_validation = true;
    };
    general_settings = {
      health_check_interval = 300;
    };
    router_settings = {
      num_retries = 2;
      allowed_fails = 3;
      cooldown_time = 30;
      routing_strategy = "simple-shuffle";
      enable_pre_call_checks = false;
      retry_policy = {
        TimeoutErrorAllowedFails = 1;
      };
    };
  };
}
