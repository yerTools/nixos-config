{ config, pkgs, hostname, hostConfig, inputs, ... }:

{
  imports = [
    ../common-home.nix
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      wallpaper = "${../../asset/image/wallpaper/firewatch-sunset.jpg}";
    };
  };

  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    thunderbird
    vscode
  ];
}
