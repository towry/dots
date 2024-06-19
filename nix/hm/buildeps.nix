{pkgs, ...}: {
  home.packages = [
    pkgs.codelldb
    pkgs.vscode-extensions.vadimcn.vscode-lldb
  ];
}
