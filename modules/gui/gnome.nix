# --- Gnome ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    gui.gnome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Gnome with all of it's dependencies.
      '';
    };
  };

  config = lib.mkIf config.modules.gui.gnome {

    # Enable Gnome
    services.xserver = {
      enable = true;

      # Enable gdm and gnome.
      displayManager.gdm.enable = true;
      desktopManager.gnome =
        assert (!(config.modules.gui.qtile && config.modules.gui.gnome));
        {
          enable = true;
        };

    };

    # Disable default bloat.
    services.gnome.core-apps.enable = false;

    # Enable sound with Pipe Wire instead.
    services.pulseaudio.enable = lib.mkForce false;
    services.pipewire.enable = lib.mkForce true;

    # System tray icons.
    environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
    services.udev.packages = with pkgs; [ gnome-settings-daemon ];

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        dconf = {
          enable = true;
          settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        };

        # Add back borers to alacrity.
        programs.alacritty.settings.window.decorations = lib.mkForce "full";

      };
  };
}
