{
  description = "My personal NixOS config :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
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
        specialArgs = { inherit hostname hostConfig inputs; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit hostname hostConfig inputs; };
              users.${hostConfig.user} = import ./hosts/${hostname}/home.nix;
              backupFileExtension = "backup";
            };
          }
        ];
      }) hosts;
    };
}
