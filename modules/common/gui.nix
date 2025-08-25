# --- GUI ---

{ config, pkgs, lib, globals, ... }:
let

  # --- Color Settings ---
  colors = {
    background = {
      main = "#14161B";
      contrast = "#0A0B0E";
    };
    foreground = {
      main = "#F2F4F3";
      soft = "#D0D6DD";
      error = "#DC4332";
    };
  };

in
{

  
  environment.systemPackages = with pkgs; [

  ];

  # Enable the X11 windowing system with qtile.
  # Include any further packages qtile requires.
  services.xserver = {

    enable = true;

    windowManager.qtile = {
      enable = true;
      extraPackages = python3Packages: with python3Packages; [
        qtile-extras
        iwlib
      ];
    };

    # Configure the login screen.
    displayManager.lightdm = {

      enable = true;

      # TODO: How can I make sure I do not start in wayland?

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
          background-color = "${colors.background.main}"
          window-color = "${colors.foreground.main}"
          border-width = 0px
          layout-space = 4
          password-color = "${colors.foreground.main}"
          password-background-color = "${colors.background.main}"
          password-border-radius = 0em
          error-color = "${colors.background.main}"
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

  # List of fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  # Use natural scrolling, as I am used to it.
  services.libinput.touchpad.naturalScrolling = true;

  # Compositor
  services.picom = {
    enable = true;
    backend = "xrender";
    vSync = true;
  };

}
