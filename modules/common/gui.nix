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

    warpd                # Keyboard mouse control and movement emulation.
    libinput-gestures    # For touchpad gestures.

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


  # Use natural scrolling, as I am used to it.
  services.libinput.touchpad.naturalScrolling = true;

  # Compositor
  # services.picom = {
  #   enable = true;
  #   backend = "xrender";
  #   vSync = true;
  # };

  # Start the libinput-gestures daemon to handle touchpad gestures.  
  systemd.services.libinput-gestures = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = globals.user;
      Restart = "always";
      ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c /home/${globals.user}/.config/libinput-gestures.conf";
    };
  };

  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  # Configuration for touchpad gestures.
  home.file.".config/libinput-gestures.conf".text = ''
    gesture swipe right 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f next_group
    gesture swipe left 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f prev_group
    gesture swipe down 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group P -f toscreen
    gesture swipe up 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group U -f toscreen
  '';

  };

}
