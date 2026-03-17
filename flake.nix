{
  description = "My personal NixOS config :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      hosts = {
        "ok-laptop-i-guess" = {
          system = "x86_64-linux";
          user = "felix";
          userDescription = "Felix";
        };
      };
    in {
      nixosConfigurations = builtins.mapAttrs (hostname: hostConfig: nixpkgs.lib.nixosSystem {
        system = hostConfig.system;
        specialArgs = { inherit hostname hostConfig; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit hostname hostConfig; };
              users.${hostConfig.user} = import ./hosts/${hostname}/home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      }) hosts;
    };
}
