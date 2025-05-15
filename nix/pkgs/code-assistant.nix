{
  version ? "0.1.6",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/stippi/code-assistant/releases/download/v${version}/code-assistant-macos-x86_64.zip";
    aarch64-darwin = "https://github.com/stippi/code-assistant/releases/download/v${version}/code-assistant-macos-aarch64.zip";
  };
  sha256-map = {
    x86_64-darwin = "1ksh6zdi6v56pmv08w11vg3hry2bagm2dxh8a0lljvb9rm10j3dv";
    aarch64-darwin = "0mn1hh5bsk5hgzpngnylp3nikwh8q807qar0iq96rms54bqh82ql";
  };
  zipfile = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "code-assistant";
  version = version;
  src = ./.;
  unpackPhase = ''
    unzip ${zipfile}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv code-assistant $out/bin/
    chmod +x $out/bin/code-assistant
  '';
  nativeBuildInputs = [
    makeWrapper
    unzip
  ];
  meta = {
    homepage = "https://github.com/stippi/code-assistant";
    description = "AI code assistant binary for macOS";
    license = lib.licenses.mit;
  };
}
