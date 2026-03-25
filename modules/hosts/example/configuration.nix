{ self, inputs, ... }: {
  
  flake.nixosModules.host-example-host-configuration = { pkgs, lib, hostConfig, ... }: {
    # This can be filled with the content from `/etc/nixos/configuration.nix`
    
    imports = [
      # ./hardware-configuration.nix - We don't import by path but rather by module name (file names don't matter).
      self.nixosModules.host-example-host-hardware
    ];

    environment.systemPackages = with pkgs; [
      firefox
      vim
    ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?

    # Fill until here LOL
  };

}