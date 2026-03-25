{ self, hostConfig, ... }: 
{
  flake.homeModules.host-example-host-home = { inputs, pkgs, hostConfig, ... }: {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];

    programs.plasma.enable = true;

    # This one is important and should be set to the same value as in the NixOS configuration.
    home.stateVersion = "25.11";
  };
}
