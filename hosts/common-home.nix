{ config, pkgs, hostname, hostConfig, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-config/config";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  
  shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos-config#${hostname}";
    update = "nix flake update --flake ${config.home.homeDirectory}/nixos-config";
    upgrade = "update && rebuild";
    neofetch = "fastfetch";
  };

  configLinks = {
    ".tmux.conf" = "tmux/tmux.conf";
    ".vim" = "vim";
  };
in
{
  home.username = hostConfig.user;
  home.homeDirectory = "/home/${hostConfig.user}";

  programs.git.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    inherit shellAliases;
  };

  home.file = builtins.mapAttrs (name: path: { source = createSymlink "${dotfiles}/${path}"; }) configLinks;

  home.packages = with pkgs; [
    gcc
    bat
    wget
    distrobox
    
    tree
    tealdeer
    fastfetch
    lazygit
    
    fzf
    ripgrep
    nodejs
    nil

    nano
    micro
    vim

    tmux
    tmuxp
    kitty
    kitty-img
    pixcat
    meowpdf
  ];
}