{ lib, pkgs, ... }:

let
  noProxyList = [
    "localhost"
    "127.0.0.1"
    "0.0.0.0"
    "registry.npmmirror.com"
    "bigmodel.cn"
    "upyun.com"
    "moonshot.cn"
    "kimi.com"
  ]
  ++ pkgs.nix-priv.keys.noProxy;
in
{
  # Domains and IPs to bypass proxy
  # Used by NO_PROXY environment variable
  noProxyList = noProxyList;

  # Format NO_PROXY list as comma-separated string
  noProxyString = lib.concatStringsSep "," noProxyList;

  proxies = {
    # use http by default
    http = "http://127.0.0.1:7898";
    https = "http://127.0.0.1:7898";
    socks5 = "socks5://127.0.0.1:7898";
  };
}
