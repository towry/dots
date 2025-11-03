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
in
rec {
  mcpServers = {
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
        "/tmp"
        "."
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
      ]
    );
    claude = mapWithClientMk clientMk.claude (
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
  };
}
