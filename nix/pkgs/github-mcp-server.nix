{
  version ? "0.19.1",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Darwin_x86_64.tar.gz";
    aarch64-darwin = "https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Darwin_arm64.tar.gz";
    x86_64-linux = "https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Linux_x86_64.tar.gz";
    aarch64-linux = "https://github.com/github/github-mcp-server/releases/download/v${version}/github-mcp-server_Linux_arm64.tar.gz";
  };
  sha256-map = {
    x86_64-darwin = "b0959bd0ef5b64cc0b12d553a4a0d764aa9e830eae0405bdd1d6728527e7a1e4";
    aarch64-darwin = "e9101f4ef92359c2e74329fb8b0c5bbeca2793fe15709fa8e047ff0a0ca42bb7";
    x86_64-linux = "a0d55e412f16e4e216002f0acf7a85fe0a1bfbfe45657a9d484c5b2b147d8e88";
    aarch64-linux = "afaccd5fead879d4bf026fbc0a4a275dba8e4ab56625354300a6ada2cc7ef6fd";
  };
  tarball = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "github-mcp-server";
  version = version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  unpackPhase = ''
    tar -xzf ${tarball}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv github-mcp-server $out/bin/
    chmod +x $out/bin/github-mcp-server
  '';
  meta = {
    homepage = "https://github.com/github/github-mcp-server";
    description = "GitHub's official MCP Server";
    license = lib.licenses.mit;
  };
}
