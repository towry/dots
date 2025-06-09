{
  version ? "21.1.0",
  system,
  pkgs ? (import <nixpkgs> { }),
}:
let
  url-map = {
    x86_64-darwin = "https://github.com/git-town/git-town/releases/download/v${version}/git-town_macos_intel_64.tar.gz";
    aarch64-darwin = "https://github.com/git-town/git-town/releases/download/v${version}/git-town_macos_arm_64.tar.gz";
  };
  sha256-map = {
    x86_64-darwin = "397fc9be31d2c9b120e5ee26d5a85635cfc3bebcf8f12b4113bfc0c45279ad08";
    aarch64-darwin = "ec279c1e0e58a00085d53e9035edacdcfcc85a2bb9ee7dace46395dad97ac154";
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
