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
      self.nixosModules.hosts-common-configuration # Add the common configuration for all machines.

      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            self.homeModules.hosts-common-home
          ];
          extraSpecialArgs = {
            inherit hostConfig inputs;
          };
          users.${hostConfig.user.name} = {
            imports = [
              self.homeModules.host-example-host-home
            ];
          };
        };
      }
      
      self.nixosModules.host-example-host-configuration # Add our machine configuration by module name, not by path.
     ];
  };

}