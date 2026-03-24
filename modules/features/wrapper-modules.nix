{ inputs, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.wrappedNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = {
        startup = {
          launcher = "fuzzel";
        };
      };
    };
  };

  flake.nixosModules.wrapperPrograms = { lib, pkgs, hostConfig, self, ... }: {
    environment.systemPackages = lib.optionals (hostConfig.enableWrappedNoctalia or false) [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wrappedNoctalia
    ];
  };
}