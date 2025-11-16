# --- Alacritty ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    apps.alacritty = lib.mkoption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Alacritty Terminal emulator.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.alacritty {

    # Remove xterm, as Alacritty becomes default.
    services.xserver = {
      desktopManager.xterm.enable = false;
      excludePackages = [ pkgs.xterm ];
    };

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        programs.alacritty.enable = true;
        programs.alacritty.settings = {

          # Set as default terminal emulator.
          env.TERM = "alacritty";

          # Configure a minimalistic GUI.
          window = {
            padding = {
              x = 6;
              y = 6;
            };
            decorations = "none";
            dynamic_title = true;
          };

          # Set background to global setting.
          colors.primary.background = globals.colors.background.main;

          # Scroll back history size.
          scrolling.history = 1000;

          # Set fonts for each different style.
          # TODO: Make font available on the machine here.
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
