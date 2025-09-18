# --- GUI ---

{ config, pkgs, lib, globals, ... }:
{


  # Enable the X11 windowing system with qtile.
  # Include any further packages qtile requires.
  services.xserver = {

    enable = true;

    # Configure the login screen.
    displayManager.lightdm = {

      enable = true;

      greeters.mini = {
        enable = true;
        user = globals.user;
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = center
          show-input-cursor = false
          [greeter-theme]
          background-image = ""
          background-color = "${globals.colors.background.main}"
          window-color = "${globals.colors.foreground.main}"
          border-width = 0px
          layout-space = 4
          password-color = "${globals.colors.foreground.main}"
          password-background-color = "${globals.colors.background.main}"
          password-border-radius = 0em
          error-color = "${globals.colors.background.main}"
          password-character = ■
        ''; 
      };
    };

    # Remove XTerm
    desktopManager.xterm.enable = false;
    excludePackages = with pkgs; [ 
      xterm
    ];

  };

  # Compositor
  services.picom = {
    enable = true;
    backend = "xrender";
    vSync = true;
  };


}
