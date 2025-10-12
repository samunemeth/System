# --- Gnome ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{
  options = {
    modules.gnome.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Gnome with all of it's dependencies.
      '';
    };
  };

  config = lib.mkIf config.modules.qtile.enable {

    # Enable Gnome
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # Disable default applications.
    environment.gnome.excludePackages = (
      with pkgs;
      [
        atomix
        cheese
        epiphany
        evince
        geary
        gedit
        gnome-characters
        gnome-music
        gnome-photos
        gnome-terminal
        gnome-tour
        hitori
        iagno
        tali
        totem
      ]
    );

    # System tray icons.
    environment.systemPackages = with pkgs; [ gnomeExtensions.appindicator ];
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

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

      };
  };
}
