# --- Qtile ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For possible local building.
  ...
}:
{

  options.modules = {
    gui.qtile = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables Qtile with all of it's dependencies.
      '';
    };
  };

  config = lib.mkIf config.modules.gui.qtile {

    # The following code makes Qtile build from a local or personal repo.
    # WARN: Make sure that the repo is based on Qtile v0.33.0 as this is the
    # > version supported by Nix at the moment.
    nixpkgs.overlays = [
      (final: prev: {
        python3 = prev.python3.override {
          packageOverrides = pyFinal: pyPrev: {
            qtile = pyPrev.qtile.overrideAttrs (old: {
              src = inputs.qtile-src;
            });
          };
        };
      })
    ];

    # Packages related to Qtile in some way.
    environment.systemPackages =
      with pkgs;
      [

        lm_sensors # Read system sensors.
        acpilight # Brightness controller.
        pulseaudio-ctl # Command line volume control.
        hsetroot # For background setting.
        libnotify # Notification handling library.
        dunst # Notification daemon.
        libinput-gestures # For touchpad gestures.

      ]
      # TODO: Handle errors if these are missing.
      ++ lib.lists.optionals config.modules.packages.lowPriority [

        numlockx # To enable NumLock by default.
        warpd # Keyboard mouse control and movement emulation.
        playerctl # For media control (play/pause).
        scrot # For screenshots.
        xcolor # For color picking.

      ];

    # Require fonts used.
    fonts.packages = [ pkgs.nerd-fonts.hack ];

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
    services.xserver.windowManager.qtile.enable =
      assert lib.assertMsg (
        !(config.modules.gui.qtile && config.modules.gui.gnome)
      ) "Multiple desktop managers are not supported.";
      true;

    # Rules for no sudo password while changing monitor brightness.
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

    # Start the daemon to handle touchpad gestures.
    systemd.services.libinput-gestures =
      let
        libinput-config-file = pkgs.writers.writeText "libinput-gestures.conf" ''
          gesture swipe left 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f next_group
          gesture swipe right 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o screen -f prev_group
          gesture swipe down 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group P -f toscreen
          gesture swipe up 3 ${pkgs.python3.pkgs.qtile}/bin/qtile cmd-obj -o group U -f toscreen
        '';
      in
      {
        enable = lib.mkDefault (if config.modules.system.isDesktop then false else true);
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = globals.user;
          Restart = "always";
          ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c ${libinput-config-file}";
        };
      };

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      let

        qtileAvailableLayouts =
          "["
          + (builtins.foldl' (acc: elem: acc + "\"" + elem + "\",") "" config.modules.locale.keyboardLayouts)
          + "]";
        hasHibernation = config.modules.system.hibernation;
        hasAutoLogin = config.modules.boot.autoLogin;

        dgpuPath = "";

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
          ".config/qtileparametric.py".text = ''

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

        };

      };

  };
}
