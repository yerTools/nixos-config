{ ... }: {
  flake.homeModules.apps-terminal-kitty = { pkgs, ... }: {
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

    home.packages = with pkgs; [
      kitty
      kitty-img
    ];
  };
}
