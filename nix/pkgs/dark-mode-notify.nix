{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  name = "dark-notify";
  version = "0.1.2";

  src = pkgs.fetchurl {
    url = "https://github.com/cormacrelf/dark-notify/releases/download/v${version}/dark-notify-v0.1.2.tar.gz";
    sha256 = "987c4e40ca9f7996f72d8967a74417e2fc7e8d7aea02e93bd314f80a80817f9a";
  };

  nativeBuildInputs = [
    # installShellFiles
    pkgs.makeBinaryWrapper
  ];

  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    mv dark-notify $out/bin/dark-notify
  '';

  postFixup = with pkgs; ''
    wrapProgram $out/bin/dark-notify \
      --set PATH ${lib.makeBinPath [
      coreutils
      bash
      python3
    ]}
  '';

  meta = {
    description = "Watcher for macOS 10.14+ light/dark mode changes";
    homepage = "https://github.com/cormacrelf/dark-notify";
  };
}
