{
  description = "Towry de dotfiles";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=24.05";
    zellij = {
      url = "github:towry/nix-flakes?dir=zellij";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # sets the home-manager's inputs of nixpkgs to be same as top-level(this one).
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls?ref=refs/tags/0.13.0";
    gitu = {
      url = "github:pze/gitu?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-darwin"
    ];
    defaultOverlay = _: prev: {
      zig = inputs.zig.packages.${prev.system}."0.13.0";
      zls = inputs.zls.packages.${prev.system}.zls;
      zellij = inputs.zellij.packages.${prev.system}.default;
      gitu = inputs.gitu.packages.${prev.system}.default;
    };
  in {
    homeConfigurations = {
      "mac-legacy" = let
        system = "x86_64-darwin";
        overlay =
          import ./nix/overlay.nix {
          };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            defaultOverlay
            overlay
            # see https://github.com/nix-community/fenix/issues/79
            (_: super: let pkgs' = inputs.fenix.inputs.nixpkgs.legacyPackages.${super.system}; in inputs.fenix.overlays.default pkgs' pkgs')
          ];
        };
      in
        home-manager.lib.homeManagerConfiguration {
          extraSpecialArgs = {
            inherit inputs outputs;
            system = system;
            theme = pkgs.callPackage ./nix/lib/theme.nix {theme = "kanagawa";};
          };
          pkgs = pkgs;
          modules = [./nix/home.nix];
        };
    };
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
