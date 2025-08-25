# --- Alacritty ---

{ config, pkgs, lib, globals, ... }:
{

  home-manager.users.${globals.user} = {
  
  programs.alacritty = {

    enable = true;

    # Configure Alacritty, the default terminal emulator.
    settings = {
      
      # This may not be supported everywhere, but this system does not have
      # xterm, and does not want to use it in any way. Some programs work
      # better with this option.
      env.TERM = "alacritty";

      window = {
        padding = {
          x = 6;
          y = 6;
        };
        decorations = "none";
        dynamic_title = true;
      };

      # Override the background color of the default theme.
      colors.primary.background = "#14161B";

      scrolling.history = 1000;

      # Set fonts for each different style.
      font = {
        normal = {
          family = "Hack Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "Hack Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "Hack Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "Hack Nerd Font Mono";
          style = "Bold Italic";
        };
        size = 8;
      };
    };
  };

  };
}
