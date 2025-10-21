# --- Qtile ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{
  options = {
    modules.qtile.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables Qtile with all of it's dependencies.
      '';
    };
    modules.qtile.processorTemperatureName = lib.mkOption {
      type = lib.types.str;
      default = "Package id 0";
      example = "Tctl";
      description = ''
        Name of the temperature sensor that shows processor temperature.
        Usually `Package id 0` for Intel or `Tctl` for AMD processors.
      '';
    };
  };

  config = lib.mkIf config.modules.qtile.enable {

    # Packages related to Qtile in some way.
    environment.systemPackages =
      with pkgs;
      [

        lm_sensors # Read system sensors.
        acpilight # Brightness controller.
        pulseaudio-ctl # Command line volume control.
        hsetroot # For background setting.
        dunst # Notification agent.
        numlockx # To enable NumLock by default.
        libinput-gestures # For touchpad gestures.
        warpd # Keyboard mouse control and movement emulation.
        xsecurelock # For secure session locking.
        xss-lock # Locking daemon.

      ]
      ++ (
        if config.modules.packages.lowPriority then
          [

            playerctl # For media control (play/pause).
            scrot # For screenshots.
            xcolor # For color picking.

          ]
        else
          [ ]
      );

    # Enable the X11 windowing system.
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

    # Enable Qtile.
    services.xserver.windowManager.qtile = {
      enable = true;
      extraPackages =
        python3Packages: with python3Packages; [
          qtile-extras
          iwlib
        ];
    };

    # Add rules so Qtile can adjust screen brightness.
    security.sudo.extraRules = lib.mkAfter [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/xbacklight";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];

    # Start the libinput-gestures daemon to handle touchpad gestures.
    systemd.services.libinput-gestures = {
      enable = lib.mkDefault (if config.modules.isDesktop then false else true);
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = globals.user;
        Restart = "always";
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c /home/${globals.user}/.config/libinput-gestures.conf";
      };
    };

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      let

        qtile_processort_temperature_name = config.modules.qtile.processorTemperatureName;
        qtile_available_layouts =
          "["
          + (builtins.foldl' (acc: elem: acc + "\"" + elem + "\",") "" config.modules.local.keyboardLayouts)
          + "]";

      in
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        # Link Qtile configuration into place.
        home.file = {

          # Main Qtile configuration files.
          ".config/qtile" = {
            source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/qtile";
            recursive = true;
          };

          # More settings for Qtile in the form of a python file containing settings.
          ".config/qtileparametric.py".text = # python
            ''

              background_main = "${globals.colors.background.main}"
              background_contrast = "${globals.colors.background.contrast}"
              foreground_main = "${globals.colors.foreground.main}"
              foreground_soft = "${globals.colors.foreground.soft}"
              foreground_error = "${globals.colors.foreground.error}"

              processor_temperature_name = "${qtile_processort_temperature_name}"
              available_layouts = ${qtile_available_layouts}

            '';

          # Settings for touchpad gestures.
          ".config/libinput-gestures.conf".text = ''
            gesture swipe left 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f next_group
            gesture swipe right 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f prev_group
            gesture swipe down 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group P -f toscreen
            gesture swipe up 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group U -f toscreen
          '';

        };

      };
  };
}
