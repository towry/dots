{
  description = "Towry de dotfiles";

  inputs = {
    nixpkgs-edge.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.11";
    home-manager = {
      # url = "github:nix-community/home-manager/release-24.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-smash = {
      url = "github:towry/nix-flakes?dir=git-smash";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls?ref=refs/tags/0.14.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitu = {
      url = "github:pze/gitu?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zjstatus.url = "github:dj95/zjstatus";
    nix-priv = {
      url = "git+ssh://git@github.com/towry/nix-priv.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jj-repo = {
      url = "git+ssh://git@github.com/pze/jj.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    asdf-elixir = {
      url = "github:asdf-vm/asdf-elixir";
      flake = false;
    };
    asdf-erlang = {
      url = "github:asdf-vm/asdf-erlang";
      flake = false;
    };
    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-edge,
      darwin,
      home-manager,
      mac-app-util,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      overlay = import ./nix/overlay.nix {
        inherit inputs;
      };
      mkSystemConfig = system: {
        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
          config.allowUnfreePredicate = true;
        };
        pkgs-edge = import nixpkgs-edge {
          inherit system;
          config.allowUnfree = true;
          config.allowUnfreePredicate = true;
        };
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnfreePredicate = true;
          overlays = [
            overlay
            # see https://github.com/nix-community/fenix/issues/79
            (
              _: super:
              let
                pkgs' = inputs.fenix.inputs.nixpkgs.legacyPackages.${super.system};
              in
              inputs.fenix.overlays.default pkgs' pkgs'
            )
          ];
        };
      };

      generateHomeConfig =
        {
          username,
          system,
        }:
        let
          inherit (mkSystemConfig system) pkgs pkgs-stable pkgs-edge;
        in
        home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs outputs;
            system = system;
            username = username;
            pkgs-stable = pkgs-stable;
            pkgs-edge = pkgs-edge;

            theme = pkgs.callPackage ./nix/lib/theme.nix { theme = "dracula"; };
          };
          pkgs = pkgs;
          modules = [
            ./nix/modules/config.nix
            ./nix/hm/vars.nix
            ./nix/home.nix
          ];
        };
    in
    {
      homeConfigurations = {
        "towry" = generateHomeConfig {
          username = "towry";
          system = "x86_64-darwin";
        };
        "momo" = generateHomeConfig {
          username = "momo";
          system = "x86_64-darwin";
        };
      };
      darwinConfigurations = (
        import ./nix/darwin {
          inherit (nixpkgs) lib;
          inherit
            mkSystemConfig
            inputs
            nixpkgs
            nixpkgs-stable
            nixpkgs-edge
            home-manager
            mac-app-util
            darwin
            ;
        }
      );
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };

  # =========================================================================
  #
  # =========================================================================

  nixConfig = {
    extra-substituters = [
      "https://dots.cachix.org"
      "https://nix-community.cachix.org"
      "https://towry.cachix.org"
      # "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "dots.cachix.org-1:H/gV3a5Ossrd/R+qrqrAk9tr3j51NHEB+pCTOk0OjYA="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "towry.cachix.org-1:7wS4ROZkLQMG6TZPt4K6kSwzbRJZf6OiyR9tWgUg3hY="
    ];
  };
}
