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
    # NOTE: This could be calculated from the value in Nvidia prime.
    modules.qtile.dgpuPath = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/sys/bus/pci/devices/0000:01:00.0";
      description = ''
        Supply a path to the dedicated gpu device to show an icon of it's status.
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
        libinput-gestures # For touchpad gestures.
        # xsecurelock # For secure session locking.
        # xss-lock # Locking daemon.

      ]
      ++ lib.lists.optionals config.modules.packages.lowPriority [

        numlockx # To enable NumLock by default.
        warpd # Keyboard mouse control and movement emulation.
        playerctl # For media control (play/pause).
        scrot # For screenshots.
        xcolor # For color picking.

      ];

    # Set up auto login if required.
    services.displayManager.autoLogin = {
      enable = config.modules.boot.autoLogin;
      user = globals.user;
    };

    # Enable the X11 windowing system.
    services.xserver = {

      enable = true;

      # Set up lightdm if there is no auto login.
      displayManager.lightdm =
        if config.modules.boot.autoLogin then
          {
            enable = true;
            greeter.enable = false;
            autoLogin.timeout = 0;
          }
        else
          {
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

    };

    # Compositor
    services.picom = {
      enable = true;
      backend = "xrender";
      vSync = true;
    };

    # Enable Qtile.
    services.xserver.windowManager.qtile =
      assert (!(config.modules.qtile.enable && config.modules.gnome.enable));
      {
        enable = true;
        extraPackages =
          python3Packages: with python3Packages; [
            qtile-extras
            iwlib
          ];
      };

    # Add rules for no sudo password.
    security.sudo.extraRules = lib.mkAfter [
      {
        commands = [
          # Changing monitor brightness.
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
      enable = lib.mkDefault (if config.modules.system.isDesktop then false else true);
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = globals.user;
        Restart = "always";
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c /home/${globals.user}/.config/libinput-gestures.conf";
      };
    };

    # send SIGUSR2 to xsecurelock on resume (post)
    # environment.etc."systemd/system-sleep/xsecurelock".text = ''
    #   #!/bin/sh
    #   if [ "$1" = "post" ]; then
    #     pkill -x -USR2 xsecurelock
    #   fi
    #   exit 0
    # '';
    # environment.etc."systemd/system-sleep/xsecurelock".mode = "0755";

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      let

        qtileAvailableLayouts =
          "["
          + (builtins.foldl' (acc: elem: acc + "\"" + elem + "\",") "" config.modules.locale.keyboardLayouts)
          + "]";
        hasHibernation = config.modules.system.hibernation;
        hasAutoLogin = config.modules.boot.autoLogin;

        dgpuPath = config.modules.qtile.dgpuPath;

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

              available_layouts = ${qtileAvailableLayouts}

              has_hibernation = ${if hasHibernation then "True" else "False"}
              has_auto_login = ${if hasAutoLogin then "True" else "False"}

              dgpu_path = "${dgpuPath}"

            '';

          # Settings for touchpad gestures.
          ".config/libinput-gestures.conf".text = ''
            gesture swipe left 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f next_group
            gesture swipe right 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f prev_group
            gesture swipe down 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group P -f toscreen
            gesture swipe up 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group U -f toscreen
          '';

          # Screenshots need a downloads directory
          "Downloads/.keep".text = "";

        };

      };
  };
}
