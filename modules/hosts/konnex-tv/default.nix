{ self, inputs, ... }:
let
  hostConfig = {
    hostname = "konnex-tv";
    user = {
      name = "konnex";
      description = "Konnex";
    };
    initialPassword = "Konnex";
    ramHome = true;
    persistentRepoPath = "/var/lib/konnex-config";
    idleCleanupHours = 6;
    nightlySoftResetTime = "*-*-* 05:00:00";
    cleanupProtectedPaths = [
      ".tmux.conf"
      ".vim"
      ".config/nvim"
    ];
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
              self.homeModules.host-konnex-tv-home
              self.homeModules.apps-terminal-kitty
            ];
          };
        };
      }
      
      self.nixosModules.host-konnex-tv-configuration # Add our machine configuration by module name, not by path.
     ];
  };

}