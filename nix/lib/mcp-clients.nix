# type = "local" | "http" | "sse"
# environment = {}
# url = ""
# command = "string"
# args = [ "string" ]
# headers

{
  lib,
  ...
}:
{
  # codex (openai/codex) config format:
  # - STDIO servers: { command, args?, env?, env_vars?, cwd?, ... }
  # - Streamable HTTP servers: { url, bearer_token_env_var?, http_headers?, env_http_headers?, ... }
  codex =
    serverAttrs:
    let
      passthru =
        lib.optionalAttrs (serverAttrs ? enabled) { inherit (serverAttrs) enabled; }
        // lib.optionalAttrs (serverAttrs ? startup_timeout_sec) {
          inherit (serverAttrs) startup_timeout_sec;
        }
        // lib.optionalAttrs (serverAttrs ? tool_timeout_sec) {
          inherit (serverAttrs) tool_timeout_sec;
        }
        // lib.optionalAttrs (serverAttrs ? enabled_tools) { inherit (serverAttrs) enabled_tools; }
        // lib.optionalAttrs (serverAttrs ? disabled_tools) { inherit (serverAttrs) disabled_tools; }
        // lib.optionalAttrs (serverAttrs ? cwd) { inherit (serverAttrs) cwd; };

      mkStdio =
        base:
        base
        // lib.optionalAttrs (serverAttrs ? environment && serverAttrs.environment != { }) {
          env = serverAttrs.environment;
        }
        // lib.optionalAttrs (serverAttrs ? env_vars && serverAttrs.env_vars != [ ]) {
          inherit (serverAttrs) env_vars;
        }
        // passthru;
    in
    if serverAttrs.type == "local" then
      mkStdio {
        inherit (serverAttrs) command;
        args = serverAttrs.args or [ ];
      }
    else if serverAttrs.type == "sse" then
      mkStdio {
        command = "bunx";
        args = [
          "mcp-remote"
          serverAttrs.url
          "--allow-http"
          "--header"
          "Authorization: ${serverAttrs.headers.Authorization}"
        ];
      }
    else
      {
        inherit (serverAttrs) url;
      }
      // lib.optionalAttrs (serverAttrs ? bearer_token_env_var) {
        inherit (serverAttrs) bearer_token_env_var;
      }
      // lib.optionalAttrs (serverAttrs ? http_headers) { inherit (serverAttrs) http_headers; }
      // lib.optionalAttrs (serverAttrs ? env_http_headers) {
        inherit (serverAttrs) env_http_headers;
      }
      // lib.optionalAttrs (serverAttrs ? headers && serverAttrs.headers != { }) {
        http_headers = serverAttrs.headers;
      }
      // passthru;

  opencode =
    let
      typeMap = {
        local = "local";
        http = "remote";
        sse = "local";
      };
    in
    serverAttrs:
    {
      type = typeMap.${serverAttrs.type};
    }
    // lib.optionalAttrs (serverAttrs ? environment) {
      inherit (serverAttrs) environment;
    }
    // (
      if serverAttrs.type == "local" then
        {
          command = [
            "${serverAttrs.command}"
          ]
          ++ (serverAttrs.args or [ ]);
        }
      else if serverAttrs.type == "sse" then
        {
          command = [
            "bunx"
            "mcp-remote"
            serverAttrs.url
            "--allow-http"
            "--header"
            # do not add extra quotes here
            "Authorization: ${serverAttrs.headers.Authorization}"
          ];
        }
      else
        {
          url = serverAttrs.url;
          headers = serverAttrs.headers or { };
        }
    );
  # claude client
  claude =
    serverAttrs:
    let
      typeMap = {
        local = "stdio";
        http = "http";
        sse = "stdio";
      };
    in
    {
      type = typeMap.${serverAttrs.type};
      env = serverAttrs.environment or { };
    }
    // (
      if serverAttrs.type == "local" then
        {
          inherit (serverAttrs) command args;
        }
      else if serverAttrs.type == "sse" then
        {
          command = "bunx";
          args = [
            "mcp-remote"
            serverAttrs.url
            "--allow-http"
            "--header"
            "'Authorization: ${serverAttrs.headers.Authorization}'"
          ];
        }
      else
        {
          inherit (serverAttrs) url;
          headers = serverAttrs.headers or { };
        }
    );
  # forge
  forge =
    serverAttrs:
    let
      typeMap = {
        local = "stdio";
        http = "http";
        sse = "stdio";
      };
    in
    {
      type = typeMap.${serverAttrs.type};
      env = serverAttrs.environment or { };
      alwaysAllow = serverAttrs.alwaysAllow or [ ];
    }
    // (
      if serverAttrs.type == "local" then
        {
          inherit (serverAttrs) command args;
        }
      else if serverAttrs.type == "sse" then
        {
          command = "bunx";
          args = [
            "mcp-remote"
            serverAttrs.url
            "--allow-http"
            "--header"
            "Authorization: ${serverAttrs.headers.Authorization}"
          ];
        }
      else
        {
          inherit (serverAttrs) url;
          headers = serverAttrs.headers or { };
        }
    );

  # copilot
  copilot =
    serverAttrs:
    let
      typeMap = {
        local = "local";
        http = "http";
        sse = "http";
      };
    in
    {
      type = typeMap.${serverAttrs.type};
      env = serverAttrs.environment or { };
      tools = serverAttrs.tools or [ ];
    }
    // (
      if serverAttrs.type == "local" then
        {
          inherit (serverAttrs) command args;
        }
      else
        {
          inherit (serverAttrs) url;
          headers = serverAttrs.headers or { };
        }
    );

  amp =
    serverAttrs:
    {
      env = serverAttrs.environment or { };
    }
    // (
      if serverAttrs.type == "local" then
        {
          inherit (serverAttrs) command args;
        }
      else if serverAttrs.type == "sse" then
        {
          command = "bunx";
          args = [
            "mcp-remote"
            serverAttrs.url
            "--allow-http"
            "--header"
            "Authorization: ${serverAttrs.headers.Authorization}"
          ];
        }
      else
        {
          url = serverAttrs.url;
          headers = serverAttrs.headers or { };
        }
    );
}
