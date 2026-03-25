{ self, inputs, ... }: {

  flake.nixosModules.host-konnex-tv-hardware = { config, lib, pkgs, modulesPath, ... }: {
    # Copy the entire content from `/etc/nixos/hardware-configuration.nix` inside.

    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/04eaa78f-ab0b-4369-87ea-6f33a222bc2b";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

    fileSystems."/home" =
      { device = "/dev/disk/by-uuid/04eaa78f-ab0b-4369-87ea-6f33a222bc2b";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/C81B-52CF";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

}