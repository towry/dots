{pkgs ? (import <nixpkgs> {}), ...}: let
  nodeDependencies = (pkgs.callPackage ./node/default.nix {}).nodeDependencies;
in
  with pkgs;
    stdenv.mkDerivation {
      pname = "node-bin";
      version = "0.0.1";
      nativeBuildInputs = [makeWrapper];
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        ln -s ${nodeDependencies}/bin/vue-language-server $out/bin/vue-language-server
        ln -s ${nodeDependencies}/bin/vtsls $out/bin/vtsls
        wrapProgram $out/bin/vue-language-server --prefix NODE_PATH: ${nodeDependencies}/lib/node_modules
        wrapProgram $out/bin/vtsls --prefix NODE_PATH: ${nodeDependencies}/lib/node_modules
      '';
      meta = {
        homepage = "https://github.com/towry";
        description = "node-bin";
        license = lib.licenses.mit;
      };
    }
