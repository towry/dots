{pkgs, ...}: {
  home.packages = [
    pkgs.cmake
    pkgs.codelldb
    pkgs.vscode-extensions.vadimcn.vscode-lldb
  ];
  home.sessionVariables = {
    ICONV_INCLUDE_DIR = "${pkgs.libiconv}/include";
    ICONV_LIBRARY = "${pkgs.libiconv}/lib";
  };
}
