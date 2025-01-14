{
  lib,
  config,
  pkgs,
  ...
}:
let
  mk_elixir_nix_version =
    elixir_version: builtins.replaceStrings [ "." ] [ "_" ] "elixir_${elixir_version}";
  beamPackages =
    pkgs.beam.packagesWith
      pkgs.beam.interpreters."erlang_${config.elixir.erlang_nix_version}";
  erlang = beamPackages.erlang;
  elixir = beamPackages.${mk_elixir_nix_version config.elixir.elixir_nix_version}.override {
    inherit erlang;
    # version = "1.17.2";
    # rev = "47abe2d107e654ccede845356773bcf6e11ef7cb";
    # sha256 = "sha256-8rb2f4CvJzio3QgoxvCv1iz8HooXze0tWUJ4Sc13dxg=";
  };
  elixir-ls = beamPackages.elixir-ls.overrideAttrs (_oldAttrs: {
    elixir = elixir;
  });
  hex = beamPackages.hex;
  # use rebar from nix instead of fetch externally
  rebar3 = beamPackages.rebar3;
in
{
  options.elixir = {
    enable = lib.mkEnableOption {
      default = false;
    };
    elixir_nix_version = lib.mkOption {
      description = "The version of elixir to use";
      example = "x.x";
      type = lib.types.str;
      default = "1.17";
    };
    erlang_nix_version = lib.mkOption {
      description = "The version of erlang to use";
      type = lib.types.str;
      default = "27";
    };
  };

  config = lib.mkIf config.elixir.enable {
    home.packages = [
      elixir
      erlang
      elixir-ls
      hex
      rebar3
    ];
    home.sessionVariables = {
      ELS_INSTALL_PREFIX = "${elixir-ls}/lib";
      MIX_PATH = "${hex}/lib/erlang/lib/hex/ebin";
      MIX_REBAR3 = "${rebar3}/bin/rebar3";
      ERL_AFLAGS = "-kernel shell_history enabled";
    };
  };
}
