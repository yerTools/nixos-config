{ config, pkgs, hostConfig, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../common-configuration.nix
    ];

  networking.wireless.enable = true;
  networking.firewall.enable = true;

  # Keep data-at-rest guarantees strong by preventing suspend/hibernate states.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  # Harden DMA behavior for external devices.
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu.strict=1"
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "poweroff";
    HandleLidSwitch = "poweroff";
    HandleLidSwitchExternalPower = "poweroff";
    HandleLidSwitchDocked = "poweroff";
    PowerKeyIgnoreInhibited = true;
    LidSwitchIgnoreInhibited = true;
  };

  services.acpid = {
    enable = true;
    # Reliable power-button fallback when a desktop daemon takes a power-key inhibitor lock.
    powerEventCommands = ''
      ${pkgs.systemd}/bin/systemctl poweroff
    '';
    # Defensive lid-close fallback: only power off when the lid state is closed.
    lidEventCommands = ''
      for state in /proc/acpi/button/lid/*/state; do
        if ${pkgs.gnugrep}/bin/grep -qi "closed" "$state"; then
          ${pkgs.systemd}/bin/systemctl poweroff
          exit 0
        fi
      done
    '';
  };

  # Use bolt to enforce Thunderbolt device authorization in userspace.
  services.hardware.bolt.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  users.users.${hostConfig.user}.packages = with pkgs; [
    kdePackages.kate
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
