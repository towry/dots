{ inputs, ... }:
let
  chromeUserDataDir = "$HOME/.local/share/chrome-user-data";
  versions = builtins.fromJSON (builtins.readFile ./pkgs/versions.json);
in
(
  final: prev:
  {
    # Skip SBCL tests that fail on macOS (known issue in 2.5.7)
    sbcl = prev.sbcl.overrideAttrs (old: {
      doCheck = false;
    });
    codelldb = final.vscode-extensions.vadimcn.vscode-lldb.adapter;
    google-chrome = prev.google-chrome.override {
      commandLineArgs = "--remote-debugging-port=9222 --disable-gpu --no-first-run --no-default-browser-check --noerrdialogs --user-data-dir=\"${chromeUserDataDir}\"";
    };

    mcp-filesystem-server = final.callPackage ./pkgs/mcp-filesystem-server.nix {
      version = versions.mcp-filesystem-server;
      pkgs = final;
      system = final.system;
    };
    # jujutsu = inputs.jj-repo.packages.${prev.system}.default;
    code-assistant = final.callPackage ./pkgs/code-assistant.nix {
      version = versions.code-assistant;
      pkgs = final;
      system = final.system;
    };
    git-town = final.callPackage ./pkgs/git-town.nix {
      pkgs = final;
      system = final.system;
    };
    # git-fuzzy = final.callPackage ./pkgs/git-fuzzy.nix {};
    uclanr = final.callPackage ./pkgs/uclanr.nix {
      pkgs = final;
      system = final.system;
    };
    starship-jj = inputs.starship-jj.packages.${prev.system}.default;
    agpod = final.callPackage ./pkgs/agpod.nix {
      version = versions.agpod;
      pkgs = final;
      system = final.system;
    };
    # nerd-font-patcher =
    #   let
    #     nerdFontPatcherVersion = "3.2.1";
    #   in
    #   prev.nerd-font-patcher.overrideAttrs (
    #     _finalAttrs: _prevAttrs: {
    #       src = prev.fetchzip {
    #         # without this, fail in unstable
    #         stripRoot = false;
    #         url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${nerdFontPatcherVersion}/FontPatcher.zip";
    #         sha256 = "sha256-3s0vcRiNA/pQrViYMwU2nnkLUNUcqXja/jTWO49x3BU=";
    #       };
    #     }
    #   );

    #-------
    switch-theme = final.callPackage ./pkgs/switch-theme/default.nix {
      pkgs = final;
    };
    dark-notify = final.callPackage ./pkgs/dark-mode-notify.nix {
      pkgs = final;
    };
    zig = inputs.zig.packages.${prev.system}."0.14.0";
    zls = inputs.zls.packages.${prev.system}.zls;
    # git-smash = inputs.git-smash.packages.${prev.system}.default;
    # gitu = inputs.gitu.packages.${prev.system}.default;
    nodejs = prev.nodejs_22;
    nodejs_22 = prev.nodejs_22;
    nodePackages = prev.nodePackages.override {
      nodejs = prev.nodejs_22;
    };
    # Python3 fixed to 3.13
    python3 = prev.python313;
    python3Packages = prev.python313Packages;
    nix-priv = inputs.nix-priv.packages.${prev.system}.default;
    # nix-ai-tools = inputs.nix-ai-tools.packages.${prev.system};
  }
  // (import ./pkgs {
    inherit inputs;
    inherit (prev) system;
    inherit (prev) pkgs;
  })
)
