{
  version ? "21.0.0",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/git-town/git-town/releases/download/v${version}/git-town_macos_intel_64.tar.gz";
    aarch64-darwin = "https://github.com/git-town/git-town/releases/download/v${version}/git-town_macos_arm_64.tar.gz";
  };
  sha256-map = {
    x86_64-darwin = "1b46c97827347f199bfd8e7dcf668d3d8c6070802499152ac10cae43fdeaaec1";
    aarch64-darwin = "0d8f003c8da45b6f5e2bf6a318d63f7db222f4f1a9e112f771558476263d7258";
  };
  tarfile = builtins.fetchurl {
    url = url-map.${system};
    sha256 = sha256-map.${system};
  };
in
with pkgs;
stdenv.mkDerivation {
  pname = "git-town";
  version = version;
  src = ./.;
  unpackPhase = ''
    tar -xzf ${tarfile}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv git-town $out/bin/
    chmod +x $out/bin/git-town
  '';
  nativeBuildInputs = [
    makeWrapper
  ];
  meta = {
    homepage = "https://github.com/git-town/git-town";
    description = "Generic, high-level Git workflow support";
    license = lib.licenses.mit;
  };
}
