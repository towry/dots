{pkgs, ...}: let
  version = "0.1.2";
  tarballUrlMap = {
    x86_64-darwin = {
      url = "https://github.com/cormacrelf/dark-notify/releases/download/v${version}/dark-notify-v0.1.2.tar.gz";
      sha256 = "987c4e40ca9f7996f72d8967a74417e2fc7e8d7aea02e93bd314f80a80817f9a";
    };
    aarch64-darwin = {
      url = "https://github.com/pze/dark-notify/releases/download/v0.1.2/dark-notify-aarch64-darwin-v0.1.2.tar.gz";
      sha256 = "0kf1ms88847j022lk7gw26zjxw9cvv3zz8xar88l0vx8f46xjss6";
    };
  };
  tarball = tarballUrlMap.${pkgs.system};
in
  pkgs.stdenv.mkDerivation {
    name = "dark-notify";
    version = version;

    src = pkgs.fetchurl tarball;

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
