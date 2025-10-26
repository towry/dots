{ lib, config, ... }:
let
  configDir = "${config.home.homeDirectory}/.config/agpod";
in
{

  # home.activation = {
  #   setupAgpodPermission = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     rm -rf ${configDir}/plugins
  #     mkdir -p ${configDir}/plugins
  #     # recursive copy with content from ./plugins_generated to ${configDir}/plugins
  #     cp -rfL ${./plugins_generated}/* ${configDir}/plugins/
  #   '';
  # };

  xdg.configFile = {
    "agpod/templates" = {
      source = ./templates;
      recursive = true;
    };
    "agpod/plugins" = {
      source = ./plugins;
      recursive = true;
    };

    "agpod/config.toml".text = ''
      # Configuration version (for tracking schema changes and deprecations)
      version = "1"

      # Kiro workflow configuration
      [kiro]
      base_dir = "llm/kiro"
      templates_dir = "~/.config/agpod/templates"
      plugins_dir = "~/.config/agpod/plugins"
      template = "default"
      summary_lines = 3

      [kiro.plugins.name]
      enabled = true
      command = "name.sh"
      timeout_secs = 3
      pass_env = ["AGPOD_*", "GIT_*", "USER", "HOME"]

      [kiro.rendering]
      files = ["design.md.j2", "tasks.md.j2"]
      extra = []
      missing_policy = "error"

      # Template-specific configurations for Kiro
      [kiro.templates.default]
      description = "Standard PR draft template with design and task documents"
      files = ["design.md.j2", "tasks.md.j2", "claude.md.j2", "requirements.md.j2"]
      missing_policy = "error"

      [kiro.templates.vue]
      description = "Vue.js component development template"
      files = ["design.md.j2", "tasks.md.j2", "claude.md.j2", "requirements.md.j2"]
      missing_policy = "error"

      # Diff minimization configuration
      [diff]
      # Default output directory for saved diff chunks
      output_dir = "llm/diff"

      # Threshold for considering a file "large" (number of changes)
      large_file_changes_threshold = 100

      # Threshold for considering a file "large" (total lines)
      large_file_lines_threshold = 500

      # Maximum consecutive empty lines to keep in output
      max_consecutive_empty_lines = 2
    '';
  };
}
