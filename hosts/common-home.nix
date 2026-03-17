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
    settings = {
      add_newline = false;
      command_timeout = 1200;

      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

      directory = {
        truncation_length = 3;
        truncation_symbol = ".../";
        style = "bold cyan";
      };

      git_branch = {
        format = " [$symbol$branch]($style)";
        symbol = "git:";
        style = "bold purple";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style))";
        style = "bold yellow";
      };

      cmd_duration = {
        min_time = 1500;
        format = " [$duration]($style)";
        style = "bold 208";
      };

      character = {
        success_symbol = "[>](bold green) ";
        error_symbol = "[>](bold red) ";
      };
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    inherit shellAliases;
    initExtra = ''
      # Tiny intro animation once per interactive shell, then clear it.
      if [[ $- == *i* ]] && [[ -z "''${BASH_FANCY_INTRO_SHOWN:-}" ]]; then
        export BASH_FANCY_INTRO_SHOWN=1
        for frame in ".  " ".. " "..."; do
          printf '\r\033[2mboot%s\033[0m' "$frame"
          sleep 0.06
        done
        printf '\r\033[2K'
      fi
    '';
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      auto_sync = true;
      update_check = false;
      search_mode = "fuzzy";
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;

      font_family = "SauceCodePro Nerd Font";
      font_size = 11;

      background_opacity = "0.96";
      window_padding_width = 6;

      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "round";

      cursor_shape = "beam";
      cursor = "#f83d19";
      cursor_blink_interval = "0.65";
      cursor_stop_blinking_after = "15.0";

      background = "#1f1515";
      foreground = "#b8bcb9";
      selection_background = "#292c31";
      selection_foreground = "#1e1e1e";

      color0 = "#3a3c43";
      color1 = "#be3e48";
      color2 = "#869a3a";
      color3 = "#c4a535";
      color4 = "#4e76a1";
      color5 = "#855b8d";
      color6 = "#568ea3";
      color7 = "#b8bcb9";
      color8 = "#888987";
      color9 = "#fb001e";
      color10 = "#0e712e";
      color11 = "#c37033";
      color12 = "#176ce3";
      color13 = "#fb0067";
      color14 = "#2d6f6c";
      color15 = "#fcffb8";
    };
  };

  home.file = builtins.mapAttrs (name: path: { source = createSymlink "${dotfiles}/${path}"; }) configLinks;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Noto Sans" "Symbols Nerd Font" "Noto Color Emoji" ];
      serif = [ "Noto Serif" "Symbols Nerd Font" "Noto Color Emoji" ];
      monospace = [ "SauceCodePro Nerd Font" "Symbols Nerd Font" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    gcc
    bat
    wget
    distrobox
    distrobox-tui
    distroshelf
    
    tree
    tealdeer
    fastfetch
    lazygit
    yazi
    btop
    eza
    atuin
    bottom
    dust
    duf
    hyperfine
    termscp
    lazydocker
    gping
    
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
    nerd-fonts.symbols-only
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