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
  ];
  "amp.permissions" = import ./permissions.nix;
}
