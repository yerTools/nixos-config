{ inputs, ... }:
let
  retroarchConfig = ''
    # Paths: keep ROMs in home and make save/state data easy to find.
    rgui_browser_directory = "~/Games/ROMs"
    system_directory = "~/.local/share/retroarch/system"
    savefile_directory = "~/.local/share/retroarch/saves"
    savestate_directory = "~/.local/share/retroarch/states"
    screenshot_directory = "~/.local/share/retroarch/screenshots"
    playlist_directory = "~/.local/share/retroarch/playlists"

    # Keep behavior predictable while still comfortable for daily use.
    config_save_on_exit = "true"
    input_autodetect_enable = "true"
    video_driver = "gl"
    menu_driver = "ozone"
    menu_show_start_screen = "true"
    load_dummy_on_core_shutdown = "true"
    sort_savefiles_enable = "true"
    sort_savestates_enable = "true"
  '';
in {
  perSystem = { pkgs, ... }: {
    packages.games-retro-retroarch = pkgs.retroarch;
    packages.games-retro-retroarch-appimage =
      inputs.nix-appimage.bundlers.${pkgs.stdenv.hostPlatform.system}.default pkgs.retroarch;

    apps.games-retro-retroarch = {
      type = "app";
      program = "${pkgs.lib.getExe pkgs.retroarch}";
    };
  };

  flake.homeModules.games-retro-retroarch = { pkgs, ... }: {
    xdg.enable = true;

    home.packages = [
      pkgs.retroarch
    ];

    xdg.configFile."retroarch/retroarch.cfg" = {
      force = true;
      text = retroarchConfig;
    };

    home.file."Games/ROMs/.keep".text = "";
    xdg.dataFile."retroarch/system/.keep".text = "";
    xdg.dataFile."retroarch/saves/.keep".text = "";
    xdg.dataFile."retroarch/states/.keep".text = "";
    xdg.dataFile."retroarch/screenshots/.keep".text = "";
    xdg.dataFile."retroarch/playlists/.keep".text = "";
  };

  flake.nixosModules.games-retro-retroarch = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.retroarch
    ];

    # Works without Home Manager: system-wide fallback config.
    environment.etc."retroarch.cfg".text = retroarchConfig;
  };
}