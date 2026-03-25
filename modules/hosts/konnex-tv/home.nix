{ self, ... }:

let
  powerdevilConfig = {
    autoSuspend.action = "nothing";
    autoSuspend.idleTimeout = null;
    turnOffDisplay.idleTimeout = "never";
    turnOffDisplay.idleTimeoutWhenLocked = null;
    dimDisplay.enable = false;
    dimKeyboard.enable = false;
    displayBrightness = 75;
    keyboardBrightness = 100;
    powerButtonAction = "shutDown";
    powerProfile = "balanced";
    whenLaptopLidClosed = "shutDown";
    whenSleepingEnter = null;
    inhibitLidActionWhenExternalMonitorConnected = false;
  };
in

{
  flake.homeModules.host-konnex-tv-home = { inputs, pkgs, ... }: {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
    ];

    # https://nix-community.github.io/plasma-manager/options.xhtml
    programs.plasma = {
      enable = true;
      workspace = {
        wallpaper = "${self}/assets/images/wallpapers/firewatch-sunset.jpg";
        theme = "breeze-dark";
        colorScheme = "BreezeDark";
        splashScreen.theme = "None";
        cursor.animationTime = 3;
      };

      kscreenlocker = {
        autoLock = false;
        lockOnResume = false;
        timeout = null;
        passwordRequired = false;
      };

      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

      input.keyboard.numlockOnStartup = "on";
      input.touchpads = [
        {
          name = "ELAN0529:00 04F3:3265 Touchpad";
          vendorId = "04f3";
          productId = "3265";
          naturalScroll = true;
        }
      ];

      powerdevil = {
        AC = powerdevilConfig;
        battery = powerdevilConfig;
        lowBattery = powerdevilConfig;
      };

      kwin.effects = {
        minimization.animation = "magiclamp";
        minimization.duration = 150;
      };

      configFile = {
        kdeglobals.General = {
          AccentColor = "255,0,0";
          TerminalApplication = "kitty";
          TerminalService = "kitty.desktop";
          font = "Noto Sans,10,-1,5,50,0,0,0,0,0";
          menuFont = "Noto Sans,10,-1,5,50,0,0,0,0,0";
          toolBarFont = "Noto Sans,10,-1,5,50,0,0,0,0,0";
          smallestReadableFont = "Noto Sans,8,-1,5,50,0,0,0,0,0";
          fixed = "SauceCodePro Nerd Font,10,-1,5,50,0,0,0,0,0";
        };
        kdeglobals.WM = {
          activeFont = "Noto Sans,10,-1,5,50,0,0,0,0,0";
        };
        kdeglobals.KDE = {
          AnimationDurationFactor = 0.35355339059327373;
        };
        plasmaparc.General = {
          RaiseMaximumVolume = true;
        };
        kwalletrc.Wallet = {
          Enabled = false;
          FirstUse = false;
        };
        kwalletrc."org.freedesktop.secrets" = {
          apiEnabled = false;
        };
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "zen-beta.desktop" "firefox.desktop" ];
        "application/xhtml+xml" = [ "zen-beta.desktop" "firefox.desktop" ];
        "application/pdf" = [ "zen-beta.desktop" "firefox.desktop" ];
        "x-scheme-handler/http" = [ "zen-beta.desktop" "firefox.desktop" ];
        "x-scheme-handler/https" = [ "zen-beta.desktop" "firefox.desktop" ];
        "x-scheme-handler/about" = [ "zen-beta.desktop" "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "zen-beta.desktop" "firefox.desktop" ];
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "message/rfc822" = [ "thunderbird.desktop" ];
        "text/plain" = [ "code.desktop" ];
      };
    };

    home.stateVersion = "25.11";
    home.packages = with pkgs; [
    ];
  };
}
