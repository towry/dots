{
  pkgs,
  lib,
}:
let
  kgApiKey = pkgs.nix-priv.keys.kg.apiKey;
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

    playwright = {
      type = "local";
      command = "bunx";
      args = [
        "@playwright/mcp@latest"
        "--executable-path"
        "google-chrome-stable"
        "--extension"
        "--output-dir=./.playwright"
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

    brightdata = {
      type = "local";
      command = "bunx";
      args = [
        "@brightdata/mcp"
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
        "claude"
        "mcp-server"
      ];
    };
  };

  clients = {
    opencode = mapWithClientMk clientMk.opencode (
      pick mcpServers [
        "kg"
        "fs"
        "context7"
        "playwright"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
        "mastergo"
      ]
    );
    claude = mapWithClientMk clientMk.claude (
      (pick mcpServers [
        "kg"
        "context7"
        "playwright"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
        "codex_smart"
        "mastergo"
      ])
      // {
        fs = mcpServers.fs_mut;
      }
    );
    forge = mapWithClientMk clientMk.forge (
      pick mcpServers [
        "kg"
        "fs"
        "context7"
        "playwright"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
      ]
    );
    copilot = mapWithClientMk clientMk.copilot (
      pick mcpServers [
        "kg"
        "fs"
        "context7"
        "playwright"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
      ]
    );
    amp = mapWithClientMk clientMk.amp (
      pick mcpServers [
        "kg"
        "fs"
        "context7"
        "playwright"
        "github"
        "mermaid"
        "brightdata"
        "sequentialthinking"
        "mastergo"
      ]
    );
  };
}
