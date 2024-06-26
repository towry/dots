{
  pkgs,
  system,
  ...
}: let
  rustlib = pkgs.callPackage ../lib/rust.nix {inherit system;};
  rustTarget = rustlib.currentPlatform.rustTarget;
  rust-toolchain = with pkgs.fenix;
    combine [
      stable.cargo
      stable.rustc
      targets.${rustTarget}.stable.rust-std
    ];
in {
  home = {
    packages = [
      rust-toolchain
      # cargo cache
      pkgs.sccache
      # background check
      pkgs.bacon
    ];
    file.".cargo/config.toml".text = ''
      [build]
      rustc-wrapper = "${pkgs.sccache}/bin/sccache"
      [net]
      git-fetch-with-cli = true
      retry = 4
    '';
  };
}
