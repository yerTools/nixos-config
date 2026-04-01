{ ... }: {

  flake.nixosModules.host-example-host-hardware = { config, lib, pkgs, modulesPath, ... }: {
    # Replace this file content with the generated /etc/nixos/hardware-configuration.nix.

    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # ...

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/1234-5678";
      fsType = "ext4";
    };

    nixpkgs.hostPlatform = "x86_64-linux";

    # Fill until here LOL
  };

}