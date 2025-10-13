{
  pkgs,
  config,
  lib,
  ...
}:
let
  claudeConfigDir = ./.; # Current directory containing all config files
  claudeTargetConfigDir = "${config.home.homeDirectory}/.claude"; # Target directory in home
  claudeUserScriptsDir = "${claudeTargetConfigDir}/scripts_"; # Directory for user scripts
  kiloSystemPromptHbs = ''
    ---
    You are in a kilo documentation driven development mode(KDDDM), you must follow the KDDDM workflow through the entire session.

    *Important*: When we say "kilo" or "kilo dir", we are referring to the KDDDM workflow directory at {{pr_dir}}.
    This is your primary documentation directory for this session.

    *What is KDDDM?*: maintain {{pr_dir}}/[CLAUDE.md,DESIGN.md,TASK.md] -> coding -> repeat.
    *DESIGN.md*:
      - contains the high-level design of a feature.
      - if this file is incomplete, you must ask the user to fill it before any implementation.
    *TASK.md*:
      - contains the current task to be done of a feature.
      - before any implementation, you must work with the user to fill this file with a clear and concise task description.
    *CLAUDE.md*:
      - contains the coding rules and guidelines, reference to documentations belong to the feature.
      - update this file frequently with notes, pitfalls, reference to context files.
      - always starts with this file, follow this file's instructions strictly.

    Our kilo documentation files are located at: {{pr_dir}}
    Please stick with {{pr_dir}} as our primary kilo documentation directory in this session.
    You can read other kilo documentations for reference, but do not update other kilo documentations outside {{pr_dir}}.
    ---
  '';

  # Process settings.json with variable substitution
  processedSettings = pkgs.replaceVars (claudeConfigDir + "/settings.json") {
    # Add any variable substitutions if needed
  };

  # Process CLAUDE.md by reading coding-rules.md and substituting @CONTENT@
  processedClaudeMd = pkgs.replaceVars (claudeConfigDir + "/assets/CLAUDE.md") {
    CONTENT = builtins.readFile ../../../../conf/llm/docs/coding-rules.md;
  };

  # Vue developer system prompt read from file
  vueSystemPrompt = builtins.readFile (claudeConfigDir + "/assets/vue-system-prompt.md");

  claudeScriptPrelude = ''
    set -euo pipefail

    export PATH="${pkgs.argc}/bin:$PATH"
    export HTTP_PROXY="http://127.0.0.1:1080"
    export HTTPS_PROXY="http://127.0.0.1:1080"
    export DISABLE_AUTOUPDATER=1
    export DISABLE_BUG_COMMAND=1
    export DISABLE_TELEMETRY=1
    export MAX_MCP_OUTPUT_TOKENS=900000
    # Suppress the init-kiro.sh info message
    export KIRO_QUIET=1
  '';

  mkClaudeWrapper = name: body: pkgs.writeShellScriptBin name ''
    ${claudeScriptPrelude}

    ${body}
  '';

  vuePromptLiteral = lib.escapeShellArg vueSystemPrompt;
  kiloPromptLiteral = lib.escapeShellArg kiloSystemPromptHbs;
  argcBinary = "${pkgs.argc}/bin/argc";

  claudeScripts = {
    claude-ai = mkClaudeWrapper "claude-ai" ''
      # Check for --pr-* arguments first, before argc processes them
      if [[ "''${1:-}" =~ ^--pr-(list|new|yolo)$ ]]; then
        # Validate --pr-new has a description argument
        if [[ "$1" == "--pr-new" && -z "''${2:-}" ]]; then
          echo "Error: --pr-new requires a description argument" >&2
          echo "Usage: claude-ai --pr-new \"description\"" >&2
          exit 1
        fi

        # Check if --role vue is in the arguments and set vue_prompt accordingly
        vue_prompt=""
        for arg in "$@"; do
          if [[ "$arg" == "vue" ]]; then
            vue_prompt=${vuePromptLiteral}
            break
          fi
        done

        kilo_prompt_template=${kiloPromptLiteral}

        # Run claude-boot.sh - stderr goes to terminal for interactivity, capture stdout (JSON)
        context_json="$(${claudeUserScriptsDir}/claude-boot.sh "$@")"
        exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
          exit $exit_code
        fi

        if [[ -z "$context_json" ]]; then
          echo "Error: claude-boot.sh returned empty output" >&2
          exit 1
        fi

        # Check if we have valid JSON context with pr_dir
        if ! pr_dir="$(printf '%s' "$context_json" | jq -r '.pr_dir // empty' 2>/dev/null)"; then
          echo "Error: Failed to parse JSON from claude-boot.sh" >&2
          exit 1
        fi

        if [[ -z "$pr_dir" ]]; then
          echo "Error: No pr_dir found in context JSON" >&2
          exit 1
        fi

        # Build system prompt based on available context
        system_prompt=""

        # Add kilo prompt if we have a PR directory
        if [[ -n "$pr_dir" && -n "$context_json" ]]; then
          # Write template to a temp file to avoid shell escaping issues
          template_file="$(mktemp)"
          printf '%s' "$kilo_prompt_template" > "$template_file"

          kilo_prompt="$(printf '%s' "$context_json" | minijinja-cli -f json "$template_file" - 2>&1)"
          minijinja_exit=$?
          rm -f "$template_file"

          if [[ $minijinja_exit -eq 0 && -n "$kilo_prompt" ]]; then
            system_prompt="$kilo_prompt"
          else
            echo "Warning: Failed to render kilo prompt template" >&2
          fi
        fi

        # Add vue prompt if it was set (--role vue was in args)
        if [[ -n "$vue_prompt" ]]; then
          if [[ -n "$system_prompt" ]]; then
            system_prompt="$system_prompt"$'\n\n'"$vue_prompt"
          else
            system_prompt="$vue_prompt"
          fi
        fi

        # If no system prompt was generated, don't pass the flag
        if [[ -n "$system_prompt" ]]; then
          exec claude --system-prompt "$system_prompt" --mcp-config "$HOME/.claude/.mcp.json"
        else
          exec claude --mcp-config "$HOME/.claude/.mcp.json"
        fi
      fi

      # Use argc to handle options so --role can appear anywhere in the CLI
      # @option --role[default|vue] Selects the runtime role preset
      # @arg argv~ Remaining arguments forwarded to claude
      eval "$(${argcBinary} --argc-eval "$0" "$@")"

      role="''${argc_role:-default}"

      if declare -p argc_argv >/dev/null 2>&1; then
        set -- "''${argc_argv[@]}"
      else
        set --
      fi

      if test "$role" != "vue"; then
        exec claude --mcp-config "$HOME/.claude/.mcp.json" "$@"
      fi

      vue_prompt=${vuePromptLiteral}
      system_prompt="$vue_prompt"

      exec claude --system-prompt "$system_prompt" --mcp-config "$HOME/.claude/.mcp.json" "$@"
    '';
  };
in
{
  # Generated files for activation script to copy
  home.file = {
    ".claude/generated/settings.json" = {
      source = processedSettings;
    };
    ".claude/generated/.mcp.json" = {
      source = claudeConfigDir + "/mcp.json";
    };
    ".claude/CLAUDE.md" = {
      source = processedClaudeMd;
    };

    # Direct symlinks for agents (read-only, won't be edited)
    ".claude/agents" = {
      source = claudeConfigDir + "/agents";
      recursive = true;
    };
    ".claude/commands" = {
      source = claudeConfigDir + "/commands";
      recursive = true;
    };
    # Claude user scripts directory for Kiro PR management
    ".claude/scripts_" = {
      source = claudeConfigDir + "/scripts_";
      recursive = true;
    };
  };

  # Activation script to copy settings.json and .mcp.json
  # These files need to be editable by the claude program
  home.activation = {
    setupClaudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      CLAUDE_DIR="${config.home.homeDirectory}/.claude"
      GENERATED_DIR="$CLAUDE_DIR/generated"

      # Create directory if it doesn't exist
      mkdir -p "$CLAUDE_DIR"

      # Always copy settings.json (override existing)
      echo "Copying settings.json to ~/.claude/"
      cp -f "$GENERATED_DIR/settings.json" "$CLAUDE_DIR/settings.json"
      chmod u+w "$CLAUDE_DIR/settings.json"

      # Always copy .mcp.json (override existing)
      echo "Copying .mcp.json to ~/.claude/"
      cp -f "$GENERATED_DIR/.mcp.json" "$CLAUDE_DIR/.mcp.json"
      chmod u+w "$CLAUDE_DIR/.mcp.json"

      echo "Claude config setup done"
    '';
  };

  home.packages = (builtins.attrValues claudeScripts) ++ [
    pkgs.minijinja
    pkgs.argc
  ];
}
