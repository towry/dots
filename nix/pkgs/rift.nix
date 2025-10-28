{
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  version = "0.0.10.1";
  tarball = builtins.fetchurl {
    url = "https://github.com/acsandmann/rift/releases/download/v${version}/rift-universal-macos-${version}.tar.gz";
    sha256 = "0wjfd08c992b7cj0q4qn114kaw1q0k8jxlhw2cz57sgw166ra3ab";
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "rift";
  version = version;
  src = tarball;
  nativeBuildInputs = [ ];
  unpackPhase = ''
    tar -xzf $src
  '';
  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 rift $out/bin/rift
    install -Dm755 rift-cli $out/bin/rift-cli
  '';
  meta = {
    homepage = "https://github.com/acsandmann/rift";
    description = "A tiling window manager for macOS";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "rift";
  };
}
