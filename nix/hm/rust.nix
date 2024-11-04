{
  pkgs,
  system,
  lib,
  ...
}: let
  rustlib = pkgs.callPackage ../lib/rust.nix {inherit system;};
  rustTarget = rustlib.currentPlatform.rustTarget;
  rust-toolchain = with pkgs.fenix;
    combine [
      stable.cargo
      stable.rustc
      stable.rust-src
      stable.rustfmt
      stable.clippy
      targets.${rustTarget}.stable.rust-std
    ];
in {
  home = {
    packages = [
      rust-toolchain
      pkgs.rust-analyzer-nightly
      # cargo cache
      pkgs.sccache
      # background check
      pkgs.bacon
      pkgs.taplo
    ];
    file.".cargo/config.toml".text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      [net]
      git-fetch-with-cli = true
      retry = 4
    '';
    sessionVariables = {
      RUST_SRC_PATH = "${rust-toolchain}/lib/rustlib/src/rust/library";
    };
  };
}
