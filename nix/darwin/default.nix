{
  home-manager,
  mac-app-util,
  mkSystemConfig,
  inputs,
  darwin,
  ...
}:
let
  mkDarwinConfig =
    {
      system,
      username,
      modules ? [ ],
    }:
    let
      inherit (mkSystemConfig system) pkgs pkgs-stable pkgs-edge;
    in
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          system
          pkgs
          pkgs-stable
          pkgs-edge
          username
          ;
      };
      modules = [
        mac-app-util.darwinModules.default
        ./configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.backupFileExtension = "bak";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.sharedModules = [
            ../modules/config.nix
            ./vars.nix
            mac-app-util.homeManagerModules.default
          ];
          home-manager.extraSpecialArgs = {
            inherit
              inputs
              system
              pkgs
              pkgs-stable
              pkgs-edge
              username
              ;
            useGlobalPkgs = true;
            theme = pkgs.callPackage ../lib/theme.nix { theme = "kanagawa"; };
          };
        }
      ] ++ modules;
    };
in
{
  towryDeMpb = mkDarwinConfig {
    system = "x86_64-darwin";
    username = "towry";
    modules = [
      ./intel.nix
    ];
  };
  momodeMac-mini = mkDarwinConfig {
    system = "aarch64-darwin";
    username = "momo";
    modules = [
      ./apple.nix
    ];
  };
  towryDeMacM2 = mkDarwinConfig {
    system = "aarch64-darwin";
    username = "momo";
    modules = [
      ./apple.nix
    ];
  };
  towryDeM3 = mkDarwinConfig {
    system = "aarch64-darwin";
    username = "towry";
    modules = [
      ./apple.nix
    ];
  };
}
