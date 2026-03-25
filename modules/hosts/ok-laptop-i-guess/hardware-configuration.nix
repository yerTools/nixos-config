{ self, inputs, ... }: {

  flake.nixosModules.host-ok-laptop-i-guess-hardware = { config, lib, pkgs, modulesPath, ... }: {
    imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/mapper/luks-bce9b9bc-a100-4703-b32b-c4ba2fdae575";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."luks-bce9b9bc-a100-4703-b32b-c4ba2fdae575".device = "/dev/disk/by-uuid/bce9b9bc-a100-4703-b32b-c4ba2fdae575";

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/680C-12E5";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/mapper/luks-5750f1ec-77ed-4bf1-9701-cff94d646a0b"; }
      ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

}