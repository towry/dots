{ pkgs, inputs, ... }:
{
  # imports = [
  #   ../modules/elixir.nix
  # ];
  # elixir.enable = true;
  home.packages = [
    pkgs.erlang
  ];
  home.file = {
    ".tool-versions".text = ''
      elixir 1.18.4-otp-27
      erlang system
    '';

    asdf-elixir = {
      source = inputs.asdf-elixir;
      target = "./.asdf/plugins/elixir";
      recursive = true;
    };
    asdf-erlang = {
      source = inputs.asdf-erlang;
      target = "./.asdf/plugins/erlang";
      recursive = true;
    };
  };
}
