{...}: (final: prev: {
  codelldb = final.vscode-extensions.vadimcn.vscode-lldb.adapter;
  path-git-format = final.callPackage ./pkgs/path-git-format.nix {
    version = "v0.0.3";
    pkgs = final;
    system = final.system;
  };
  git-fuzzy = final.callPackage ./pkgs/git-fuzzy.nix {};
  uclanr = final.callPackage ./pkgs/uclanr.nix {
    pkgs = final;
    system = final.system;
  };
})
