{ self, inputs, ... }:
let
  hostConfig = {
    hostname = "ok-laptop-i-guess";
    user = {
      name = "felix";
      description = "Felix";
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
            inherit hostConfig inputs;
          };
          users.${hostConfig.user.name} = {
            imports = [
              self.homeModules.host-ok-laptop-i-guess-home
            ];
          };
        };
      }
      
      self.nixosModules.host-ok-laptop-i-guess-configuration
     ];
  };

}