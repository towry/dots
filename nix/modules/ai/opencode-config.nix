{ ... }:
{
  # OpenCode configuration as Nix attrset
  config = {
    "$schema" = "https://opencode.ai/config.json";
    small_model = "github-copilot/grok-code-fast-1";
    autoupdate = false;
    username = "TOWRY 😜";
    disabled_providers = [
      "openai"
      "gemini"
      "openrouter"
      "moonshotai"
      "deepseek"
      "perplexity"
    ];
    instructions = [ ];
    keybinds = { };
    tui = {
      scroll_speed = 1;
    };

    agent = {
      review = {
        model = "github-copilot/gpt-5";
        prompt = "{file:./roles/lifeguard.md}";
        description = "Code review and code quality assurance";
        mode = "all";
        tools = {
          write = false;
          edit = false;
          bash = true;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = false;
          todoread = false;
          webfetch = false;
          "tavily*" = true;
          "github*" = true;
          lifeguard = false;
        };
        permission = {
          edit = "deny";
          bash = {
            "*" = "deny";
            "jj log" = "allow";
            "jj diff" = "allow";
            "rg" = "allow";
            "ast-grep" = "allow";
            "fd" = "allow";
            "ls" = "allow";
            "head" = "allow";
            "tail" = "allow";
            "git show" = "allow";
            "git diff" = "allow";
            "git log" = "allow";
            "git reflog" = "allow";
            "git status" = "allow";
            "jj git-diff" = "allow";
            "jj df-names" = "allow";
            "jj show" = "allow";
            "jj file" = "allow";
            "jj operation log" = "allow";
          };
        };
      };

      kiro = {
        model = "github-copilot/claude-sonnet-4.5";
        prompt = "{file:./roles/kiro.md}";
        description = "Kiro spec workflow";
        mode = "primary";
        tools = {
          write = false;
          edit = true;
          bash = false;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = true;
          todoread = true;
          webfetch = false;
          "tavily*" = true;
          lifeguard = true;
          "sequentialthinking*" = true;
        };
        permission = {
          edit = "allow";
          bash = "deny";
          webfetch = "deny";
        };
      };

      build = {
        model = "zhipuai-coding-plan/glm-4.6";
        tools = {
          write = true;
          edit = true;
          bash = true;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = true;
          todoread = true;
          webfetch = false;
          "tavily*" = true;
          "github*" = true;
          "fs*" = true;
          lifeguard = true;
          "sequentialthinking*" = true;
        };
        permission = {
          bash = {
            "*" = "allow";
            "rm -rf" = "deny";
            "git push" = "ask";
            "git commit" = "ask";
            "git pull" = "ask";
            "git fetch" = "ask";
            "jj ci" = "ask";
            "jj git" = "ask";
            "jj commit" = "ask";
            "ssh" = "ask";
            "cargo run" = "ask";
          };
        };
      };

      super = {
        model = "github-copilot/claude-sonnet-4.5";
        description = "Super AI developer assistant";
        mode = "primary";
        prompt = "You are Super, a highly capable AI assistant specialized in software development. Your goal is to assist the user in completing their software development tasks efficiently and effectively. Always ensure to follow best practices and maintain code quality.";
        tools = {
          write = true;
          edit = true;
          bash = true;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = true;
          todoread = true;
          webfetch = false;
          "tavily*" = true;
          "github*" = true;
          "fs*" = true;
          lifeguard = true;
          "sequentialthinking*" = true;
        };
        permission = {
          bash = {
            "*" = "allow";
            "rm -rf" = "deny";
            "git push" = "ask";
            "git commit" = "ask";
            "git pull" = "ask";
            "git fetch" = "ask";
            "jj ci" = "ask";
            "jj git" = "ask";
            "jj commit" = "ask";
            "ssh" = "ask";
            "cargo run" = "ask";
          };
        };
      };

      plan = {
        mode = "primary";
        model = "github-copilot/gpt-5";
        prompt = "{file:./roles/oracle.md}";
        tools = {
          write = false;
          edit = false;
          bash = false;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = true;
          todoread = true;
          webfetch = false;
          "tavily*" = true;
          "github*" = true;
          lifeguard = true;
          "fs_read*" = true;
          "fs_search*" = true;
          "fs_list*" = true;
          "fs_find*" = true;
          "fs_directory_tree" = true;
          "sequentialthinking*" = true;
        };
        permission = {
          bash = "deny";
          edit = "deny";
        };
      };

      bender = {
        mode = "primary";
        model = "github-copilot/gpt-5-mini";
        prompt = "{file:./roles/oracle.md}";
        tools = {
          write = false;
          edit = false;
          bash = true;
          grep = true;
          read = true;
          list = true;
          glob = true;
          todowrite = true;
          todoread = true;
          webfetch = false;
          "tavily*" = true;
          "github*" = true;
          lifeguard = true;
          "fs_read*" = true;
          "fs_search*" = true;
          "fs_list*" = true;
          "fs_find*" = true;
          "sequentialthinking*" = true;
        };
        permission = {
          bash = "deny";
          edit = "deny";
        };
      };
    };

    provider = {
      moonshotai-cn = {
        npm = "@ai-sdk/openai-compatible";
        name = "Moonshot-AI CN";
        options = {
          apiKey = "{env:MOONSHOT_API_KEY}";
          baseURL = "https://api.moonshot.cn/v1";
        };
        models = {
          kimi-k2 = {
            id = "kimi-k2-0905-preview";
            name = "Kimi K2";
          };
        };
      };

      litellm = {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM";
        options = {
          apiKey = "{env:LITELLM_MASTER_KEY}";
          baseURL = "http://127.0.0.1:4000";
        };
      };

      openrouter = {
        npm = "@openrouter/ai-sdk-provider";
        name = "OpenRouter";
        options = {
          apiKey = "{env:OPENROUTER_API_KEY}";
        };
        models = {
          gpt-5-codex-low = {
            id = "openai/gpt-5-codex";
            name = "GPT-5 Codex Low";
            options = {
              reasoningEffort = "low";
              textVerbosity = "low";
              reasoningSummary = "auto";
            };
          };
          gpt-5-codex-medium = {
            id = "openai/gpt-5-codex";
            name = "GPT-5 Codex Medium";
            options = {
              reasoningEffort = "medium";
              textVerbosity = "low";
              reasoningSummary = "auto";
            };
          };
          gpt-5-medium = {
            id = "openai/gpt-5";
            name = "GPT-5 Medium";
            options = {
              reasoningEffort = "medium";
              textVerbosity = "low";
              reasoningSummary = "auto";
            };
          };
          "openai/gpt-5" = {
            name = "GPT-5";
            options = {
              reasoningEffort = "medium";
              textVerbosity = "low";
              reasoningSummary = "auto";
            };
          };
          "x-ai/grok-4-fast" = {
            name = "Grok 4 Fast";
            tool_call = true;
            attachment = true;
          };
          "x-ai/grok-code-fast-1" = {
            name = "Grok Code Fast 1";
            tool_call = true;
            attachment = true;
          };
          "z-ai/glm-4.6" = {
            name = "GLM 4.6";
            tool_call = true;
            attachment = true;
          };
        };
      };
    };

    permission = {
      bash = {
        "*" = "ask";
        test = "allow";
        mkdir = "allow";
        grep = "allow";
        mv = "allow";
        cp = "allow";
        ps = "allow";
        lsof = "allow";
        mktemp = "allow";
        curl = "allow";
        pbcopy = "allow";
        xargs = "allow";
        agpod = "allow";
        echo = "allow";
        rg = "allow";
        "git diff" = "allow";
        "git show" = "allow";
        "git status" = "allow";
        "git log" = "allow";
        "jj log" = "allow";
        "jj git-diff" = "allow";
        "jj df-names" = "allow";
        "jj diff" = "allow";
        "jj show" = "allow";
        "jj file" = "allow";
        "ast-grep" = "allow";
        head = "allow";
        tail = "allow";
        cat = "allow";
        fd = "allow";
        ls = "allow";
        cd = "allow";
      };
      edit = "allow";
      webfetch = "deny";
    };

    tools = {
      webfetch = false;
      "playwright*" = false;
      "github*" = false;
      "context7*" = false;
      "mermaid*" = true;
      "tavily*" = true;
      "kg*" = true;
      "sequentialthinking*" = false;
    };

    lsp = {
      typescript.disabled = true;
      deno.disabled = true;
      eslint.disabled = true;
      gopls.disabled = true;
      ruby-lsp.disabled = true;
      pyright.disabled = true;
      elixir-ls.disabled = true;
      zls.disabled = true;
      csharp.disabled = true;
      vue.disabled = true;
      rust.disabled = true;
      clangd.disabled = true;
      svelte.disabled = true;
      astro.disabled = true;
      jdtls.disabled = true;
      lua-ls.disabled = true;
    };
  };
}
