{ config, pkgs, hostname, hostConfig, inputs, ... }:

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
  imports = [
    ../common-home.nix
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  # https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;
    workspace = {
      wallpaper = "${../../asset/image/wallpaper/firewatch-sunset.jpg}";
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
      };
      kdeglobals.KDE = {
        AnimationDurationFactor = 0.35355339059327373;
      };
      plasmaparc.General = {
        RaiseMaximumVolume = true;
      };
    };
  };

  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    thunderbird
    vscode
  ];
}
