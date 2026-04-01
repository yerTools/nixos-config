{ ... }: {

  flake.nixosModules.host-ok-laptop-i-guess-hardware = { config, lib, pkgs, modulesPath, ... }: {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/mapper/luks-3f8621a5-2a02-470f-bb42-7cc23502bdd5";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

    boot.initrd.luks.devices."luks-3f8621a5-2a02-470f-bb42-7cc23502bdd5".device = "/dev/disk/by-uuid/3f8621a5-2a02-470f-bb42-7cc23502bdd5";

    fileSystems."/home" =
      { device = "/dev/mapper/luks-3f8621a5-2a02-470f-bb42-7cc23502bdd5";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/E591-B430";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

}
