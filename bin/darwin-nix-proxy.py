"""
  Set proxy for nix-daemon to speed up downloads
  You can safely ignore this file if you don't need a proxy.

  https://github.com/NixOS/nix/issues/1472#issuecomment-1532955973
"""
import os
import plistlib
import shlex
import subprocess
from pathlib import Path


# Support both traditional Nix and Determinate Nix Installer
NIX_DAEMON_PLIST_PATHS = [
    Path("/Library/LaunchDaemons/systems.determinate.nix-daemon.plist"),  # Determinate Nix
    Path("/Library/LaunchDaemons/org.nixos.nix-daemon.plist"),  # Traditional Nix
]

NIX_DAEMON_PLIST = None
for plist_path in NIX_DAEMON_PLIST_PATHS:
    if plist_path.exists():
        NIX_DAEMON_PLIST = plist_path
        break

if NIX_DAEMON_PLIST is None:
    print("Error: No nix-daemon plist found. Tried:")
    for p in NIX_DAEMON_PLIST_PATHS:
        print(f"  - {p}")
    raise SystemExit(1)

print(f"Using plist: {NIX_DAEMON_PLIST}")

# http proxy provided by clash or other proxy tools
# Use environment variable or default value
HTTP_PROXY = os.environ.get("HTTP_PROXY", "http://127.0.0.1:7898")

pl = plistlib.loads(NIX_DAEMON_PLIST.read_bytes())

# Ensure EnvironmentVariables key exists
if "EnvironmentVariables" not in pl:
    pl["EnvironmentVariables"] = {}

# set http/https proxy
# NOTE: curl only accept the lowercase of `http_proxy`!
# NOTE: https://curl.se/libcurl/c/libcurl-env.html
pl["EnvironmentVariables"]["http_proxy"] = HTTP_PROXY
pl["EnvironmentVariables"]["https_proxy"] = HTTP_PROXY

# remove http proxy
# pl["EnvironmentVariables"].pop("http_proxy", None)
# pl["EnvironmentVariables"].pop("https_proxy", None)

os.chmod(NIX_DAEMON_PLIST, 0o644)
NIX_DAEMON_PLIST.write_bytes(plistlib.dumps(pl))
os.chmod(NIX_DAEMON_PLIST, 0o444)

# reload the plist
for cmd in (
	f"launchctl unload {NIX_DAEMON_PLIST}",
	f"launchctl load {NIX_DAEMON_PLIST}",
):
    print(cmd)
    subprocess.run(shlex.split(cmd), capture_output=False)
