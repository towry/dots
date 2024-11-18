{
  system,
  pkgs ? (import <nixpkgs> {}),
}: let
  version = "2.1.0";
  # NOTE: the tar must contain file only.
  # tar -czvf xxxx.tar.gz ./somefile
  tarballUrlMap = {
    x86_64-darwin = "https://github.com/Axlefublr/uclanr/releases/download/${version}/uclanr-x86_64-apple-darwin.tar.gz";
    aarch64-darwin = "https://github.com/pze/uclanr/releases/download/v0.0.2/uclanr-aarch64-darwin.tar.gz";
  };
  tarballUrl = tarballUrlMap.${system};
  sha256-map = {
    x86_64-darwin = "0jr6iwll1sb02yp9l31k119jan7dy0liyw729ci49mjvhwnb5jsh";
    aarch64-darwin = "1dghijdk2i3j95f4nl1hg6y94kllbavicykqpgdf1b9vmrxj1yq1";
  };
  tarbar = builtins.fetchurl {
    url = tarballUrl;
    sha256 = sha256-map.${system};
  };
in
  with pkgs;
    stdenv.mkDerivation {
      pname = "uclanr";
      version = version;
      nativeBuildInputs = [makeWrapper];
      src = ./.;
      unpackPhase = ''
        tar -xvzf ${tarbar}
      '';
      installPhase = ''
        mkdir -p $out/bin
        chmod +x ./uclanr
        mv ./uclanr $out/bin/
        wrapProgram $out/bin/uclanr
      '';
      meta = {
        homepage = "https://github.com/Axlefublr/uclanr";
        description = "Generate random word";
        license = lib.licenses.mit;
      };
    }
