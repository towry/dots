{
  pkgs,
  config,
  lib,
  ...
}:

{
  home.packages = [ pkgs.gopls ];

  programs = {
    go.enable = true;
  };

  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/workspace/goenv";
  };

  home.activation = {
    ensureGoPathDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p ${config.home.homeDirectory}/workspace/goenv
    '';
  };
}
