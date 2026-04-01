{ ... }: {
  
  flake.nixosModules.hosts-common-configuration = { config, pkgs, lib, hostConfig, ... }:
  
  let
    ramHomeEnabled = hostConfig.ramHome or false;
    nixosConfigPath =
      if ramHomeEnabled then
        (hostConfig.persistentRepoPath or "/home/${hostConfig.user.name}/nixos-config")
      else
        "/home/${hostConfig.user.name}/nixos-config";
  in
  {
    networking.hostName = hostConfig.hostname;

    boot.loader.timeout = lib.mkDefault 3;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };

    console.keyMap = "de";

    users.users.${hostConfig.user.name} = {
      isNormalUser = true;
      description = hostConfig.user.description;
      extraGroups = [ "networkmanager" "wheel" ];
    };

    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    programs.firefox.enable = true;
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.sauce-code-pro
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      source-sans
      source-serif
      source-code-pro
    ];

    system.autoUpgrade = {
      enable = true;
      allowReboot = false;
      flake = "${nixosConfigPath}#${hostConfig.hostname}";
    };

    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];

    environment.systemPackages = with pkgs; [
      git
    ];
  };

}