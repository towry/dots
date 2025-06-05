{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    ## Docker
    docker
    docker-credential-helpers
    colima
  ];

  # Docker configuration can be added here
  xdg.configFile = {
    colima = {
      enable = true;
      source = ../../conf/colima;
      recursive = true;
    };
  };
}
