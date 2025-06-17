{
  version ? "0.0.53",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/opencode-ai/opencode/releases/download/v${version}/opencode-mac-x86_64.tar.gz";
    aarch64-darwin = "https://github.com/opencode-ai/opencode/releases/download/v${version}/opencode-mac-arm64.tar.gz";
    x86_64-linux = "https://github.com/opencode-ai/opencode/releases/download/v${version}/opencode-linux-x86_64.tar.gz";
    aarch64-linux = "https://github.com/opencode-ai/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
  };
  sha256-map = {
    x86_64-darwin = "d7e798df5404ab49f72539772fc886cce3478965d59e0f8fb51809daa508106f";
    aarch64-darwin = "dd2c49d5ed1ff4d98787666d41a772bdcc4595eb02805563293450ff85896ac6";
    x86_64-linux = "1d2b57f9a6ede223c50e865409289bb7e263620bb9b18151f3776974f08ea39f";
    aarch64-linux = "c2f8c9fe365815a13e5789291c133fb6e6312d95e4c5ad7cd5ee4823fd57c68e";
  };
  tarfile = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "opencode";
  inherit version;
  src = ./.;
  unpackPhase = ''
    tar -xzf ${tarfile}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv opencode $out/bin/
    chmod +x $out/bin/opencode
  '';
  nativeBuildInputs = [
    makeWrapper
  ];
  meta = {
    homepage = "https://github.com/opencode-ai/opencode";
    description = "OpenCode AI CLI tool";
    license = lib.licenses.mit;
  };
}
