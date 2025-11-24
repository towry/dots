{
  version,
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    aarch64-darwin = "https://github.com/towry/agpod/releases/download/v${version}/agpod-${version}-aarch64-apple-darwin.tar.gz";
  };
  sha256-map = {
    aarch64-darwin = "sha256-f7DO96PhNmOBW9DxNBO0P58uO3mAcCrzzwNIRGLdCKY=";
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "agpod";
  inherit version;
  src = fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
  sourceRoot = "agpod-${version}-aarch64-apple-darwin";
  installPhase = ''
    mkdir -p $out/bin
    mv agpod $out/bin/
    chmod +x $out/bin/agpod
  '';
  nativeBuildInputs = [
    makeWrapper
  ];
  meta = {
    homepage = "https://github.com/towry/agpod";
    description = "A tool for managing AI-powered development workflows";
    license = lib.licenses.mit;
  };
}
