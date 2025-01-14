{
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "git-fuzzy";
in
stdenv.mkDerivation {
  pname = name;
  version = "41b7691";

  src = fetchFromGitHub {
    owner = "bigH";
    repo = name;
    rev = "41b7691a837e23e36cec44e8ea2c071161727dfa";
    sha256 = "sha256-fexv5aesUakrgaz4HE9Nt954OoBEF06qZb6VSMvuZhw=";
  };

  installPhase = ''
    runHook preInstall
    cp -r . $out/
    runHook postInstall
  '';
}
