{ self, inputs, ... }:
let
  hostConfig = {
    hostname = "example-host";
    user = {
      name = "example-user";
      description = "Example User";
    };
  };
in 
{
  flake.nixosConfigurations.${hostConfig.hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit hostConfig inputs;
    };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.hosts-common-configuration

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            self.homeModules.hosts-common-home
          ];
          extraSpecialArgs = {
            inherit hostConfig inputs self;
          };
          users.${hostConfig.user.name} = {
            imports = [
              self.homeModules.host-example-host-home
              self.homeModules.apps-terminal-kitty
            ];
          };
        };
      }
      
      self.nixosModules.host-example-host-configuration
     ];
  };

}