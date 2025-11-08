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
    aarch64-darwin = "0mx1x01843pnhc7vidfnnj5axwm2ifdzyzwvhkd43ky85xgc81rs";
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
