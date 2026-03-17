{ config, pkgs, hostname, hostConfig, inputs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-config/config";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  treeSitterCli = pkgs.rustPlatform.buildRustPackage {
    pname = "tree-sitter";
    version = "0.26.7";
    src = pkgs.fetchCrate {
      pname = "tree-sitter-cli";
      version = "0.26.7";
      hash = "sha256-JlF/cQgCWrTqvfZdIRwY15z1hQwiyiioqlGy9IyRQOw=";
    };
    cargoHash = "sha256-k0GvEiI5gbxkT6blzHflVmMc+2slR53CrktIGDMjlWw=";
    nativeBuildInputs = with pkgs; [ pkg-config installShellFiles which rustPlatform.bindgenHook ];
    buildInputs = with pkgs; [ openssl ];
    doCheck = false;
  };
  
  shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/nixos-config#${hostname}";
    update = "nix flake update --flake ${config.home.homeDirectory}/nixos-config";
    upgrade = "update && rebuild";
    neofetch = "fastfetch";
  };

  configLinks = {
    ".tmux.conf" = "tmux/tmux.conf";
    ".vim" = "vim";
    ".config/nvim" = "nvim-config";
  };
in
{
  home.username = hostConfig.user;
  home.homeDirectory = "/home/${hostConfig.user}";

  programs.git = {
    enable = true;
    settings.user.name = "Felix Mayer";
    settings.user.email = "FelixM@yer.tools";
  };

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
    rust-analyzer

    nano
    micro
    vim
    neovim

    curl
    fd
    treeSitterCli
    (python3.withPackages (ps: [ ps.pip ]))
    lua5_1
    nerd-fonts.sauce-code-pro
    unzip
    luarocks
    yarn
    gzip
    lsof
    sqlite
    ghostscript
    tectonic
    texliveSmall
    mermaid-cli

    tmux
    tmuxp
    kitty
    kitty-img
    pixcat
    meowpdf
    
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}