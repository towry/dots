{
  version ? "0.9.0",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/mark3labs/mcp-filesystem-server/releases/download/v${version}/mcp-filesystem-server_darwin_amd64.tar.gz";
    aarch64-darwin = "https://github.com/mark3labs/mcp-filesystem-server/releases/download/v${version}/mcp-filesystem-server_darwin_arm64.tar.gz";
  };
  sha256-map = {
    x86_64-darwin = "2a6bbbe300ad05d7d4bfc69dc9f22920325f3dc81cf6a07398e2c8ee30ef19a2";
    aarch64-darwin = "97b4100952bbbb5d6c988651692515e225e0a38c319c74a5319ff3466c43cbbc";
  };
  tarball = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "mcp-filesystem-server";
  version = version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  unpackPhase = ''
    tar -xvzf ${tarball}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv mcp-filesystem-server $out/bin/
    chmod +x $out/bin/mcp-filesystem-server
  '';
  meta = {
    homepage = "https://github.com/mark3labs/mcp-filesystem-server";
    description = "Filesystem server for MCP";
    license = lib.licenses.mit;
  };
}
