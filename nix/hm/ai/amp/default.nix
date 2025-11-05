{
  config,
  lib,
  pkgs,
  ...
}:
let
  proxyConfig = import ../../../lib/proxy.nix { inherit lib; };
  mcpServers = import ../../../modules/ai/mcp.nix { inherit lib pkgs; };
  ampConfigDir = config.xdg.configHome + "/amp";
  ampSettingFilePath = ampConfigDir + "/settings.json";
  ampSettingJson = builtins.toJSON (
    import ./settings.nix {
      inherit
        lib
        pkgs
        proxyConfig
        mcpServers
        ;
    }
  );
in

{
  home.activation = {
    setupAmpConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${ampConfigDir}

      # Write AMP settings
      cp ${pkgs.writeText "amp-settings.json" ampSettingJson} ${ampSettingFilePath}

      echo "🧕🏻 AMP config setup done"
    '';
  };
  xdg.configFile = {
    "amp/commands" = {
      source = ./commands;
      recursive = true;
    };
  };
}
