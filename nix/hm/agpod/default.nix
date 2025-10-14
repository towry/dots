{ pkgs, ...}: {
    xdg.configFile = {
      "agpod/templates" = {
        source = ./templates;
        recursive = true;
      };

      "agpod/config.toml".text = ''
        base_dir = "llm/kiro"
        templates_dir = "~/.config/agpod/templates"
        plugins_dir = "~/.config/agpod/plugins"
        template = "vue"
        summary_lines = 3

        [plugins.name]
        enabled = true
        command = "name.sh"
        timeout_secs = 3
        pass_env = ["AGPOD_*", "GIT_*", "USER", "HOME"]

        [rendering]
        files = ["DESIGN.md.j2", "TASK.md.j2"]
        extra = []
        missing_policy = "error"

        # Template-specific configurations
        [templates.vue]
        files = ["DESIGN.md.j2", "TASK.md.j2", "CLAUDE.md.j2"]
        missing_policy = "error"
      '';
    };
}
