{ config, pkgs, hostname, hostConfig, ... }:

{
  imports = [
    ../common-home.nix
  ];

  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    thunderbird
    vscode
  ];
}
