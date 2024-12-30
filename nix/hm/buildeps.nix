{
  pkgs,
  lib,
  config,
  ...
}: let
  path-prefix = config.vars.path-prefix.value;
in {
  home.packages = [
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.cmake
    # pkgs.codelldb
    # build cache.
    pkgs.sccache
    pkgs.iconv
    pkgs.libiconv
    pkgs.gettext
    # pkgs.vscode-extensions.vadimcn.vscode-lldb
    pkgs.openssl
    pkgs.readline
  ];
  home.sessionVariables = lib.mkIf config.vars.path-prefix.enable {
    CPATH = "${path-prefix}/include";
    C_INCLUDE_PATH = "${path-prefix}/include";
    CPLUS_INCLUDE_PATH = "${path-prefix}/include";
    LDFLAGS = "-L${path-prefix}/lib";
    CFLAGS = "-I${path-prefix}/include";
    CPPFLAGS = "-I${path-prefix}/include";
    LD_LIBRARY_PATH = "${path-prefix}/lib";
    DYLD_LIBRARY_PATH = "${path-prefix}/lib";
    LIBS = "-L${path-prefix}/lib -Wl,-rpath,${path-prefix}/lib";
    PKG_CONFIG_PATH = "${path-prefix}/lib/pkgconfig";
    DYLD_FALLBACK_LIBRARY_PATH = "${path-prefix}/lib";
  };
}
