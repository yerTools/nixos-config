{ ... }:
{
  flake.homeModules.apps-launcher-walker = { pkgs, ... }: {
    home.packages = with pkgs; [
      walker
      elephant
      wl-clipboard
      cliphist
      libqalculate
      rofimoji
      bitwarden-cli
    ];

    xdg.configFile."walker/config.toml".text = ''
      exact_search_prefix = "'"
      theme = "default"
      disable_mouse = false
      hide_action_hints = false
      hide_quick_activation = true
      force_keyboard_focus = true

      [providers]
      default = ["desktopapplications", "calc", "clipboard", "symbols", "websearch"]
      empty = ["desktopapplications"]
      max_results = 60

      [[providers.prefixes]]
      prefix = "="
      provider = "calc"

      [[providers.prefixes]]
      prefix = ":"
      provider = "clipboard"

      [[providers.prefixes]]
      prefix = "."
      provider = "symbols"

      [[providers.prefixes]]
      prefix = "@"
      provider = "websearch"

      # Optional: works when elephant has the bitwarden provider installed.
      [[providers.prefixes]]
      prefix = ","
      provider = "bitwarden"

      [providers.clipboard]
      time_format = "relative"

      [providers.actions]
      bitwarden = [
        { action = "copypassword", label = "copy password", default = true, bind = "Return" },
        { action = "copyusername", label = "copy username", bind = "shift Return" },
        { action = "copyotp", label = "copy 2fa", bind = "ctrl Return" },
        { action = "syncvault", label = "sync", bind = "ctrl s" },
      ]
    '';

    xdg.configFile."elephant/websearch.toml".text = ''
      # Default websearch engine for Walker's @ prefix.
      [[entries]]
      default = true
      name = "DuckDuckGo"
      prefix = "ddg"
      url = "https://duckduckgo.com/?q=%TERM%"

      [[entries]]
      name = "DuckDuckGo Bangs"
      prefix = "!"
      url = "https://duckduckgo.com/?q=%TERM%"
    '';

    systemd.user.services.cliphist-text = {
      Unit = {
        Description = "Watch text clipboard history (RAM only)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        Environment = [ "XDG_CACHE_HOME=%t" ];
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.cliphist-image = {
      Unit = {
        Description = "Watch image clipboard history (RAM only)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        Environment = [ "XDG_CACHE_HOME=%t" ];
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.walker-service = {
      Unit = {
        Description = "Walker gapplication service for fast launch";
        PartOf = [ "graphical-session.target" ];
        After = [ "elephant.service" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.elephant = {
      Unit = {
        Description = "Elephant provider backend";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.elephant}/bin/elephant";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    programs.plasma = {
      hotkeys.commands = {
        launcher-walker = {
          name = "Walker Launcher";
          comment = "Universal launcher: apps, calculator, clipboard, symbols";
          key = "Alt+Space";
          command = "${pkgs.walker}/bin/walker";
        };

        launcher-emoji = {
          name = "Emoji Picker";
          comment = "Fallback emoji picker";
          key = "Meta+Period";
          command = "${pkgs.rofimoji}/bin/rofimoji --action copy";
        };
      };

      krunner = {
        shortcuts.launch = "Alt+F2";
        historyBehavior = "disabled";
      };
    };
  };
}