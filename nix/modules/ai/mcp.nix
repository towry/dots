{
  pkgs,
  lib,
  config,
  ...
}:
let
  kgApiKey = pkgs.nix-priv.keys.kg.apiKey;
  chromeUserData = "${config.home.homeDirectory}/.local/state/chrome-user-data";
  kgSse = pkgs.nix-priv.keys.kg.sse;
  pick = attrs: keys: lib.attrsets.filterAttrs (name: _: lib.lists.elem name keys) attrs;
  clientMk = import ../../lib/mcp-clients.nix { inherit lib; };
  mapWithClientMk = clientMk: servers: lib.mapAttrs (name: value: clientMk value) servers;
  fs_tools = [
    "read_text_file"
    "create_directory"
    "directory_tree"
    "list_directory"
    "read_multiple_text_files"
    "search_files"
    "search_code_ast"
    "search_files_content"
    "read_file_lines"
    "find_duplicate_files"
  ];
in
rec {
  mcpServers = rec {
    mastergo = {
      type = "local";
      command = "bunx";
      args = [
        "@mastergo/magic-mcp"
        "--token"
        "${pkgs.nix-priv.keys.mastergo.token}"
        "--url=https://mastergo.com"
      ];
    };
    kg = {
      type = "sse";
      url = kgSse;
      headers = {
        "Authorization" = "Bearer ${kgApiKey}";
      };
    };

    fs = {
      type = "local";
      command = "rust-mcp-filesystem";
      args = [
        "~/workspace"
        "."
        "/tmp"
        "--tools"
        "${lib.concatStringsSep "," fs_tools}"
      ];
    };

    fs_mut = {
      inherit (mcpServers.fs) type command;
      args = [
        "~/workspace"
        "."
        "/tmp"
        "--allow-write"
        "--tools"
        "${lib.concatStringsSep "," (
          fs_tools
          ++ [
            "write_file"
            "edit_file"
            "move_file"
            "copy_file"
          ]
        )}"
      ];
    };

    context7 = {
      type = "local";
      command = "bunx";
      args = [
        "@upstash/context7-mcp"
      ];
      environment = { };
    };

    chromedev = {
      type = "local";
      command = "bunx";
      args = [
        "chrome-devtools-mcp@latest"
        "--browser-url=http://127.0.0.1:9222"
      ];
    };

    github = {
      type = "local";
      command = "github-mcp-server";
      args = [
        "stdio"
        "--dynamic-toolsets"
      ];
      environment = {
        GITHUB_PERSONAL_ACCESS_TOKEN = pkgs.nix-priv.keys.github.accessToken;
      };
    };

    mermaid = {
      type = "local";
      command = "bunx";
      args = [
        "mcp-mermaid"
      ];
    };

    tavily = {
      type = "local";
      command = "bunx";
      args = [
        "mcp-remote"
        "${pkgs.nix-priv.keys.tavily.mcpUrl}"
      ];
      environment = {
        HTTP_PROXY = "http://127.0.0.1:7898";
        HTTPS_PROXY = "http://127.0.0.1:7898";
      };
    };

    brightdata = {
      type = "local";
      command = "bunx";
      args = [
        "@brightdata/mcp@2.6.1"
      ];
      environment = {
        API_TOKEN = pkgs.nix-priv.keys.brightdata.apiKey;
      };
    };

    sequentialthinking = {
      type = "local";
      command = "bunx";
      args = [
        "@modelcontextprotocol/server-sequential-thinking"
      ];
      environment = { };
    };

    codex_smart = {
      type = "local";
      command = "codex-ai";
      args = [
        "--profile"
        "gpt"
        "mcp-server"
      ];
    };

    codex_chromedev = {
      type = "local";
      command = "codex-ai";
      args = [
        "--profile"
        "chromedev"
        "mcp-server"
      ];
    };
  };

  clients = {
    opencode = mapWithClientMk clientMk.opencode (
      pick mcpServers [
        "kg"
        "fs"
        "chromedev"
        "github"
        "brightdata"
        "mastergo"
      ]
    );
    claude = mapWithClientMk clientMk.claude (
      (pick mcpServers [
        "kg"
        # "chromedev"
        "github"
        "brightdata"
        "mastergo"
        "codex_chromedev"
      ])
    );
    forge = mapWithClientMk clientMk.forge (
      pick mcpServers [
        "kg"
        "fs"
        "chromedev"
        "github"
        "brightdata"
        "sequentialthinking"
      ]
    );
    copilot = mapWithClientMk clientMk.copilot (
      pick mcpServers [
        "kg"
        "fs"
        "chromedev"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
      ]
    );
    amp = mapWithClientMk clientMk.amp (
      pick mcpServers [
        "kg"
        "chromedev"
        "github"
        "brightdata"
        "sequentialthinking"
        "mastergo"
      ]
    );
  };
}
