# https://ampcode.com/manual#configuration
{ proxyConfig, mcpServers, ... }:
{
  "amp.git.commit.ampThread.enabled" = false;
  "amp.updates.mode" = "disabled";
  "amp.git.commit.coauthor.enabled" = false;
  "amp.dangerouslyAllowAll" = false;
  # Use the shared project proxy
  "amp.proxy" = proxyConfig.proxies.http;
  "mp.experimental.planMode" = true;
  "amp.mcpServers" = mcpServers.clients.amp;
  "amp.mcpPermissions" = [
    # action: "reject"|"allow"|"ask"
    # matches#command: string/glob string
    # matches#args: string/glob string
    # matches#url: string/glob string (for http type)
    #####
    # {
    #   matches = {
    #     command = "bunx";
    #     args = "@playwright/mcp@*";
    #   };
    #   action = "ask";
    # }
  ];
  "amp.permissions" = [
    {
      tool = "Bash";
      matches = {
        cmd = "*git commit*";
        action = "ask";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "curl";
        action = "allow";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "*git ci*";
        action = "ask";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "sleep";
        action = "allow";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "*jj commit*";
        action = "ask";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "*jj ci*";
        action = "ask";
      };
    }
    {
      tool = "mcp__playwright_*";
      action = "allow";
    }
    {
      tool = "mcp__kg_*";
      action = "allow";
    }
    {
      tool = "Bash";
      matches = {
        cmd = "tail *";
        action = "allow";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "head *";
        action = "allow";
      };
    }
    {
      tool = "Bash";
      matches = {
        cmd = "cd *";
        action = "allow";
      };
    }
    ## Delegate everything else to a permission helper (must be on $PATH)
    # {
    #   "tool" = "*";
    #   "action" = "delegate";
    #   "to" = "my-permission-helper";
    # }
  ];
}
