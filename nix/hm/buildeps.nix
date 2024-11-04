{
  pkgs,
  config,
  ...
}: let
  homeDir = config.home.homeDirectory;
in {
  home.packages = [
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.cmake
    pkgs.codelldb
    # build cache.
    pkgs.sccache
    pkgs.iconv.out
    pkgs.iconv.dev
    pkgs.libiconv
    pkgs.gettext
    pkgs.vscode-extensions.vadimcn.vscode-lldb
    pkgs.openssl.bin
    pkgs.openssl.dev
    pkgs.openssl.out
    pkgs.readline.dev
    pkgs.readline.out
  ];
  home.sessionVariables = {
    CPATH = "${config.home.homeDirectory}/.nix-profile/include";
    C_INCLUDE_PATH = "${config.home.homeDirectory}/.nix-profile/include";
    CPLUS_INCLUDE_PATH = "${config.home.homeDirectory}/.nix-profile/include";
    LDFLAGS = "-L${homeDir}/.nix-profile/lib";
    CFLAGS = "-I${homeDir}/.nix-profile/include";
    CPPFLAGS = "-I${homeDir}/.nix-profile/include";
    LD_LIBRARY_PATH = "${homeDir}/.nix-profile/lib";
    DYLD_LIBRARY_PATH = "${homeDir}/.nix-profile/lib";
    LIBS = "-L${homeDir}/.nix-profile/lib -Wl,-rpath,${homeDir}/.nix-profile/lib";
    PKG_CONFIG_PATH = "${homeDir}/.nix-profile/lib/pkgconfig";
    DYLD_FALLBACK_LIBRARY_PATH = "${config.home.homeDirectory}/.nix-profile/lib";
  };
}
