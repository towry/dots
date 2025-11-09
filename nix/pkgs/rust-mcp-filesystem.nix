{
  version,
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    aarch64-darwin = "https://github.com/towry/rust-mcp-filesystem/releases/download/v${version}/rust-mcp-filesystem-aarch64-apple-darwin.tar.gz";
  };
  sha256-map = {
    aarch64-darwin = "c447fb2b9317989eba3a1d77135491a475494273f15bec4273176d1304f9f1b3";
  };
  tarball = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "rust-mcp-filesystem";
  version = version;
  src = ./.;
  nativeBuildInputs = [ makeWrapper ];
  unpackPhase = ''
    tar -xvzf ${tarball}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv rust-mcp-filesystem-aarch64-apple-darwin/rust-mcp-filesystem $out/bin/
    chmod +x $out/bin/rust-mcp-filesystem
  '';
  meta = {
    homepage = "https://github.com/rust-mcp-stack/rust-mcp-filesystem";
    description = "Rust-based filesystem server for MCP";
    license = lib.licenses.mit;
  };
}
