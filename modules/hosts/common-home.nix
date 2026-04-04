{ self, ... }: {
  flake.homeModules.hosts-common-home = { config, pkgs, lib, hostConfig, inputs, ... }:
  let
    ramHomeEnabled = hostConfig.ramHome or false;
    idleCleanupHours = hostConfig.idleCleanupHours or 0;
    cleanupEnabled = ramHomeEnabled && idleCleanupHours > 0;
    cleanupUnitName = "${hostConfig.user.name}-idle-home-cleanup";
    nightlySoftResetTime = hostConfig.nightlySoftResetTime or "";
    nightlySoftResetEnabled = ramHomeEnabled && nightlySoftResetTime != "";
    nightlyResetUnitName = "${hostConfig.user.name}-nightly-soft-reset";
    nixosConfigPath =
      if ramHomeEnabled then
        (hostConfig.persistentRepoPath or "${config.home.homeDirectory}/nixos-config")
      else
        "${config.home.homeDirectory}/nixos-config";
    dotfiles = "${nixosConfigPath}/dotfiles";
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
      update = "nix flake update --flake ${nixosConfigPath}";
      upgrade = "update && rebuild";
      neofetch = "fastfetch";
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --icons --git";
      la = "eza -lah --icons --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=plain";
    } // lib.optionalAttrs cleanupEnabled {
      cleanup = "sudo systemctl start ${cleanupUnitName}.service";
      cleanup-status = "systemctl status ${cleanupUnitName}.service ${cleanupUnitName}.timer --no-pager -l";
    } // lib.optionalAttrs nightlySoftResetEnabled {
      nightly-reset = "sudo systemctl start ${nightlyResetUnitName}.service";
      nightly-reset-status = "systemctl status ${nightlyResetUnitName}.service ${nightlyResetUnitName}.timer --no-pager -l";
    };

    configLinks = {
      ".tmux.conf" = "tmux/tmux.conf";
      ".vim" = "vim";
      ".config/nvim" = "nvim-config";
    };
  in
  {
    home.username = hostConfig.user.name;
    home.homeDirectory = "/home/${hostConfig.user.name}";

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1200;

        format = "[](fg:color_orange)$username[](fg:color_orange bg:color_yellow)$directory[](fg:color_yellow bg:color_aqua)$git_branch$git_status[](fg:color_aqua bg:color_bg3)$cmd_duration$time[](fg:color_bg3)$line_break$status$character";

        palette = "gruvbox_dark";
        palettes.gruvbox_dark = {
          color_fg0 = "#fff4d8";
          color_bg1 = "#2b0f14";
          color_bg3 = "#4a1b22";
          color_aqua = "#8f2d35";
          color_orange = "#b92d1f";
          color_red = "#ff4d4d";
          color_yellow = "#d7b347";
        };

        username = {
          show_always = true;
          format = "[  ]($style)";
          style_root = "bg:color_orange fg:color_red bold";
          style_user = "bg:color_orange fg:color_fg0 bold";
        };

        directory = {
          truncation_length = 6;
          truncation_symbol = ".../";
          format = "[ $path$read_only ]($style)";
          style = "fg:color_bg1 bg:color_yellow bold";
          read_only = "󰌾";
        };

        git_branch = {
          format = "[ $symbol$branch ]($style)";
          symbol = " ";
          style = "fg:color_fg0 bg:color_aqua bold";
        };

        git_status = {
          format = "[($all_status$ahead_behind )]($style)";
          style = "fg:color_fg0 bg:color_aqua bold";
          conflicted = "=\${count}";
          ahead = "⇡\${count}";
          behind = "⇣\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          untracked = "?\${count}";
          stashed = "*\${count}";
          modified = "!\${count}";
          staged = "+\${count}";
          renamed = "»\${count}";
          deleted = "✘\${count}";
        };

        cmd_duration = {
          min_time = 1000;
          format = "[ 󱎫 $duration ]($style)";
          style = "fg:color_fg0 bg:color_bg3";
        };

        time = {
          disabled = false;
          time_format = "%H:%M";
          format = "[  $time ]($style)";
          style = "fg:color_yellow bg:color_bg3 bold";
        };

        status = {
          disabled = false;
          symbol = "✖ ";
          success_symbol = "✔ ";
          format = "[$symbol$status ]($style)";
          style = "bold fg:color_red";
          success_style = "bold fg:color_aqua";
        };

        character = {
          success_symbol = "[](bold fg:color_aqua) ";
          error_symbol = "[](bold fg:color_red) ";
        };
      };
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      dotDir = config.home.homeDirectory;
      inherit shellAliases;

      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        share = true;
      };

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [ "git" "fzf" "zoxide" ];
      };

      plugins = [
        {
          name = "zsh-autocomplete";
          src = pkgs.zsh-autocomplete;
          file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
        }
      ];

      initContent = ''
        # Completion stays fast and forgiving without changing core behavior.
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select

        rebuild() {
          local usage action target input
          usage='Usage: rebuild [now] [{path to NixOS config}/{hostname}/{path#hostname}]'
          action='build'
          target='${nixosConfigPath}#${hostConfig.hostname}'
          input=""

          if [ "$#" -gt 2 ]; then
            echo "$usage" >&2
            return 2
          fi

          if [ "$#" -eq 1 ]; then
            if [ "$1" = 'now' ]; then
              action='switch'
            else
              input="$1"
            fi
          elif [ "$#" -eq 2 ]; then
            if [ "$1" != 'now' ]; then
              echo "$usage" >&2
              return 2
            fi
            action='switch'
            input="$2"
          fi

          if [ -n "$input" ]; then
            case "$input" in
              *#*)
                target="$input"
                ;;
              *)
                if [ -d "$input" ]; then
                  target="$input#${hostConfig.hostname}"
                else
                  case "$input" in
                    */*|*[!A-Za-z0-9._-]*)
                      target="$input#${hostConfig.hostname}"
                      ;;
                    *)
                      target='${nixosConfigPath}'"#$input"
                      ;;
                  esac
                fi
                ;;
            esac
          fi

          sudo nixos-rebuild "$action" --flake "$target"
        }

        _rebuild_target_values() {
          local -a hosts
          local hosts_dir='${nixosConfigPath}/hosts'
          local expl ret=1

          if [ -d "$hosts_dir" ]; then
            hosts=("$hosts_dir"/*(/N:t))
          else
            hosts=()
          fi

          if [ "$#hosts" -gt 0 ]; then
            _wanted hosts expl 'hostname' compadd -a hosts && ret=0
          fi

          _wanted files expl 'path' _files && ret=0
          return "$ret"
        }

        _rebuild_completion() {
          if [ "$CURRENT" -eq 2 ]; then
            compadd -- now
            _rebuild_target_values
            return
          fi

          if [ "$CURRENT" -eq 3 ] && [ "$words[2]" = 'now' ]; then
            _rebuild_target_values
            return
          fi

          _message 'Usage: rebuild [now] [{path}/{hostname}/{path#hostname}]'
        }

        compdef _rebuild_completion rebuild

        # Prefix-aware history search: type a prefix, then use arrow keys.
        autoload -U up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search
        bindkey "^[[B" down-line-or-beginning-search

        # Starship renders the prompt; Oh My Zsh provides plugin ergonomics.
      '';
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      inherit shellAliases;
      initExtra = ''
        rebuild() {
          local usage action target input
          usage='Usage: rebuild [now] [{path to NixOS config}/{hostname}/{path#hostname}]'
          action='build'
          target='${nixosConfigPath}#${hostConfig.hostname}'
          input=""

          if [ "$#" -gt 2 ]; then
            echo "$usage" >&2
            return 2
          fi

          if [ "$#" -eq 1 ]; then
            if [ "$1" = 'now' ]; then
              action='switch'
            else
              input="$1"
            fi
          elif [ "$#" -eq 2 ]; then
            if [ "$1" != 'now' ]; then
              echo "$usage" >&2
              return 2
            fi
            action='switch'
            input="$2"
          fi

          if [ -n "$input" ]; then
            case "$input" in
              *#*)
                target="$input"
                ;;
              *)
                if [ -d "$input" ]; then
                  target="$input#${hostConfig.hostname}"
                else
                  case "$input" in
                    */*|*[!A-Za-z0-9._-]*)
                      target="$input#${hostConfig.hostname}"
                      ;;
                    *)
                      target='${nixosConfigPath}'"#$input"
                      ;;
                  esac
                fi
                ;;
            esac
          fi

          sudo nixos-rebuild "$action" --flake "$target"
        }
      '';
    };

    programs.atuin = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        update_check = false;
        search_mode = "fuzzy";
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      defaultOptions = [
        "--height=45%"
        "--layout=reverse"
        "--border=rounded"
        "--preview-window=right,60%,border-left"
        "--bind=ctrl-/:toggle-preview"
        "--color=fg:#b8bcb9,bg:#1f1515,hl:#d7b347,fg+:#fff4d8,bg+:#2b0f14,hl+:#ff4d4d,info:#8f2d35,prompt:#b92d1f,pointer:#ff4d4d,marker:#d7b347,spinner:#8f2d35,header:#b92d1f"
      ];
      fileWidgetOptions = [ "--preview 'bat --style=numbers --color=always --line-range :300 {}'" ];
      changeDirWidgetOptions = [ "--preview 'eza --tree --level=2 --icons --color=always {} | head -200'" ];
      historyWidgetOptions = [ "--sort" "--exact" ];
    };

    programs.carapace = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
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
      go
      bun
      gopls
      vtsls
      lua-language-server
      stylua
      marksman
      eslint_d
      prettier
      vscode-langservers-extracted
      typescript

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

      typst
      typstyle
      tinymist
      ltex-ls-plus
      websocat

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
      pixcat
      meowpdf
      
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      google-chrome
      kdePackages.kcalc
    ];

  };
}