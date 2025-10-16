{
  pkgs,
  config,
  lib,
  ...
}:

let
  # Cline global rules directory for macOS
  clineRulesDir = "${config.home.homeDirectory}/Documents/Cline/Rules";

  # Process coding rules content for Cline
  processedClineRules = pkgs.replaceVars (../../../../conf/llm/docs/coding-rules.md) {
    # Add any variable substitutions if needed
  };

  # Cline script prelude with environment variables
  clineScriptPrelude = ''
    set -euo pipefail

    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"
    # Disable auto-updater and telemetry if needed
    export DISABLE_AUTOUPDATER=1
    export DISABLE_TELEMETRY=1
  '';

  # Create wrapper scripts for Cline if needed
  mkClineWrapper =
    name: body:
    pkgs.writeShellScriptBin name ''
      ${clineScriptPrelude}

      ${body}
    '';

  clineScripts = {
    # Add any custom Cline scripts here if needed
    cline-ai = mkClineWrapper "cline-ai" ''
      # Run cline with custom configuration
      exec cline "$@"
    '';
  };

in
{
  # Home file configurations for Cline
  home.file = {
    # Main coding rules as global rule
    "${clineRulesDir}/coding-rules.md" = {
      source = processedClineRules;
    };
  };

  # Activation script to ensure Cline rules directory exists and is properly set up
  home.activation = {
    setupClineRules = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Create Cline rules directory if it doesn't exist
      mkdir -p "${clineRulesDir}"

      # Ensure proper permissions
      chmod -R 755 "${clineRulesDir}"

      echo "Cline global rules setup completed"
      echo "Global rules location: ${clineRulesDir}"
    '';
  };

  # Add any required packages
  home.packages = (builtins.attrValues clineScripts) ++ [
    # Add any Cline-related packages here
  ];

  # Optional: Add shell aliases for Cline
  programs.fish = {
    interactiveShellInit = ''
      if test -n "$CLINE_ACTIVE"
        set -x PAGER cat
        set -x GIT_PAGER cat
        set -x SYSTEMD_PAGER cat
        set -x LESS -FRX
      end
    '';
  };
}
