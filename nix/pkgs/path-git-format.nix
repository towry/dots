{
  version ? "latest",
  system,
  pkgs ? (import <nixpkgs> {}),
}: let
  tarballUrl =
    if version == "latest"
    then "https://github.com/towry/path-git-format/releases/latest/download/path-git-format.tar.gz"
    else "https://github.com/towry/path-git-format/releases/download/${version}/path-git-format-${version}-${system}.tar.gz";
  sha256-map = {
    x86_64-darwin = "065rhg8pdjj9w87xbw3s9jd9al250nb98jlbqvgw655g996zqvbz";
    aarch64-darwin = "0kc3ar8kkm8whabdlpcz4x7y4hrk2v6vv1v4zfzxxx2kw0kjsx3a";
  };
  tarbar = builtins.fetchurl {
    url = tarballUrl;
    sha256 = sha256-map.${system};
  };
  libs = [
    pkgs.openssl_3
  ];
in
  with pkgs;
    stdenv.mkDerivation {
      pname = "path-git-format";
      version = version;
      nativeBuildInputs = [makeWrapper];
      src = ./.;
      unpackPhase = ''
        tar -xvzf ${tarbar}
      '';
      installPhase = ''
        mkdir -p $out/bin
        mv ./path-git-format $out/bin/
        wrapProgram $out/bin/path-git-format --set DYLD_FALLBACK_LIBRARY_PATH ${lib.makeLibraryPath libs}
      '';
      meta = {
        homepage = "https://github.com/towry/path-git-format";
        description = "Utils to format path with git repo info from stdin";
        license = lib.licenses.mit;
      };
    }
