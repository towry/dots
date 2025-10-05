{
  pkgs,
  lib,
  config,
  ...
}:
let
  path-prefix = config.vars.path-prefix.value;
in
{
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
    pkgs.sqlite
    # pkgs.vscode-extensions.vadimcn.vscode-lldb
    pkgs.openssl
    pkgs.readline
  ];
  home.sessionVariables = lib.mkIf config.vars.path-prefix.enable {
    # Include paths: nix-profile, homebrew, system defaults
    CPATH = "${path-prefix}/include:/opt/homebrew/include:/usr/local/include:/usr/include";
    C_INCLUDE_PATH = "${path-prefix}/include:/opt/homebrew/include:/usr/local/include:/usr/include";
    CPLUS_INCLUDE_PATH = "${path-prefix}/include:/opt/homebrew/include:/usr/local/include:/usr/include";

    # Library paths and flags
    LDFLAGS = "-L${path-prefix}/lib -L/opt/homebrew/lib -L/usr/local/lib -L/usr/lib";
    CFLAGS = "-I${path-prefix}/include -I/opt/homebrew/include -I/usr/local/include -I/usr/include";
    CPPFLAGS = "-I${path-prefix}/include -I/opt/homebrew/include -I/usr/local/include -I/usr/include";

    # Runtime library paths
    LD_LIBRARY_PATH = "${path-prefix}/lib:/opt/homebrew/lib:/opt/homebrew/Cellar/libiconv/1.18/lib:/usr/local/lib:/usr/lib";
    DYLD_LIBRARY_PATH = "${path-prefix}/lib:/opt/homebrew/lib:/opt/homebrew/Cellar/libiconv/1.18/lib";
    DYLD_FALLBACK_LIBRARY_PATH = "${path-prefix}/lib:/opt/homebrew/lib:/opt/homebrew/Cellar/libiconv/1.18/lib";

    # Linker flags with rpath
    LIBS = "-L${path-prefix}/lib -Wl,-rpath,${path-prefix}/lib -L/opt/homebrew/lib -Wl,-rpath,/opt/homebrew/lib";

    # pkg-config paths
    PKG_CONFIG_PATH = "${path-prefix}/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig";
  };
}
