# https://github.dev/MatthiasBenaets/nix-config/blob/master/hosts/default.nix
{
  home-manager,
  mkSystemConfig,
  inputs,
  darwin,
  vars,
  ...
}: let
  mkDarwinConfig = {
    system,
    username,
    modules ? [],
  }: let
    inherit (mkSystemConfig system) pkgs pkgs-stable;
  in
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit inputs system pkgs pkgs-stable vars username;};
      modules =
        [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs system pkgs pkgs-stable vars username;
              useGlobalPkgs = true;
              theme = pkgs.callPackage ../../lib/theme.nix {theme = "kanagawa";};
            };
          }
        ]
        ++ modules;
    };
in {
  towryDeMacbook = mkDarwinConfig {
    system = "x86_64-darwin";
    username = "towry";
    modules = [
      ./intel.nix
    ];
  };
  momodeMac-mini = mkDarwinConfig {
    system = "x86_64-darwin";
    username = "momo";
    modules = [
      ./intel.nix
    ];
  };
}
