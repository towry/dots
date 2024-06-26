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
  nerd-font-patcher = let
    nerdFontPatcherVersion = "3.2.1";
  in
    prev.nerd-font-patcher.overrideAttrs (finalAttrs: prevAttrs: {
      src = prev.fetchzip {
        url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerdFontPatcherVersion}/FontPatcher.zip";
        sha256 = "sha256-3s0vcRiNA/pQrViYMwU2nnkLUNUcqXja/jTWO49x3BU=";
      };
    });
})
