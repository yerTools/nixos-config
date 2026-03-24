{
  description = "My personal NixOS config :3";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    
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

  outputs = inputs:
    let
      featureTree = inputs.import-tree ./modules/features;
    in
    inputs.flake-parts.lib.mkFlake
      { inherit inputs; }
      (featureTree // {
        systems = [ "x86_64-linux" ];

        imports = (featureTree.imports or [ ]) ++ [
          ./modules/hosts/default.nix
        ];
      });
}
