{
  lib,
  config,
  pkgs,
  ...
}:
let
  beamPackages = pkgs.beam.packages.erlang_27;
  erlang = beamPackages.erlang;
  elixir = beamPackages.elixir_1_18;
  hex = beamPackages.hex;
  # use rebar from nix instead of fetch externally
  rebar3 = beamPackages.rebar3;
in
{
  options.elixir = {
    enable = lib.mkEnableOption {
      default = false;
    };
  };

  config = lib.mkIf config.elixir.enable {
    home.packages = [
      elixir
      erlang
      hex
      rebar3
    ];
    home.sessionVariables = {
      # ELS_INSTALL_PREFIX = "${elixir-ls}/lib";
      MIX_PATH = "${hex}/lib/erlang/lib/hex/ebin";
      MIX_REBAR3 = "${rebar3}/bin/rebar3";
      ERL_AFLAGS = "-kernel shell_history enabled";
    };
  };
}
