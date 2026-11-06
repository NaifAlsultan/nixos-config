{
  description = "Unified NixOS configuration for desktop and laptop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      mkHost =
        hostName: hostModules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.naif = {
                imports = [
                  ./home/common.nix
                  ./home/linux.nix
                ];
                home.stateVersion = "24.11";
              };
              networking.hostName = hostName;
            }
          ]
          ++ hostModules;
        };
    in
    {
      nixosConfigurations = {
        desktop = mkHost "desktop" [
          ./hosts/desktop/hardware-configuration.nix
          ./hosts/desktop/file-sharing.nix
        ];

        laptop = mkHost "laptop" [
          ./hosts/laptop/hardware-configuration.nix
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
