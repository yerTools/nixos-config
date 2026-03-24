{ self, inputs, ... }:
let
  lib = inputs.nixpkgs.lib;

  hosts = {
    ok-laptop-i-guess = {
      system = "x86_64-linux";
      user = "felix";
      userDescription = "Felix";
    };

    konnex-tv = {
      system = "x86_64-linux";
      user = "konnex";
      userDescription = "Konnex";
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
      enableWrappedNoctalia = true;
    };
  };

  mkNixos = hostname: hostConfig:
    lib.nixosSystem {
      system = hostConfig.system;
      specialArgs = {
        inherit self inputs hostname hostConfig;
      };
      modules = [
        (./. + "/${hostname}/configuration.nix")
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.wrapperPrograms
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit self inputs hostname hostConfig;
            };
            users.${hostConfig.user} = import (./. + "/${hostname}/home.nix");
            backupFileExtension = "backup";
          };
        }
      ];
    };

  mkHome = hostname: hostConfig:
    let
      pkgs = import inputs.nixpkgs {
        system = hostConfig.system;
        config.allowUnfree = true;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit self inputs hostname hostConfig;
      };
      modules = [
        (./. + "/${hostname}/home.nix")
      ];
    };
in
{
  flake = {
    nixosConfigurations = lib.mapAttrs mkNixos hosts;

    homeConfigurations = lib.mapAttrs'
      (hostname: hostConfig:
        lib.nameValuePair "${hostConfig.user}@${hostname}" (mkHome hostname hostConfig))
      hosts;
  };
}