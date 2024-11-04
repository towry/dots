{pkgs, ...}: {
  home.packages = [
    pkgs.pkg-config
    pkgs.cmake
    pkgs.codelldb
    # build cache.
    pkgs.sccache
    pkgs.vscode-extensions.vadimcn.vscode-lldb
  ];
  home.sessionVariables = {
    ICONV_INCLUDE_DIR = "${pkgs.libiconv}/include";
    ICONV_LIBRARY = "${pkgs.libiconv}/lib";
  };
}
