{config, ...}: {
  vars = {
    path-prefix = {
      value = "${config.home.homeDirectory}/.nix-profile";
      enable = true;
    };
  };
  elixir.enable = true;
}
