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
