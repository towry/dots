{ ...}: {
  imports = [
    ../modules/elixir.nix
  ];
  elixir.enable = true;
  home.file.".tool-versions".text = ''
  elixir system
  erlang system
  '';
}
