# --- Qtile ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For possible local building.
  ...
}:
let
  qtile-package = inputs.qtile-flake.packages.${globals.system}.default;
in
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

      ]
      # TODO: Handle errors if these are missing.
      ++ lib.lists.optionals config.modules.packages.lowPriority [

        numlockx # To enable NumLock by default.
        warpd # Keyboard mouse control and movement emulation.
        playerctl # For media control (play/pause).
        scrot # For screenshots.
        xcolor # For color picking.

      ];

    # NOTE: Some stuff relating to tablet mode on convertibles:
    # > libinput # Exposing for other system info.
    # > rot8 # Automatic display rotation helper.
    # > My convertible hp laptop has there messages when folding over and back:
    # > -event15 SWITCH_TOGGLE +4.283s	switch tablet-mode state 1
    # >  event15 SWITCH_TOGGLE +12.837s switch tablet-mode state 0
    # > Maybe add rot8 for automatic rotation?
    # > Needs a systemd service, and probably not supported by all laptops.

    # Require fonts used.
    fonts.packages = [ pkgs.nerd-fonts.hack ];

    # Request Google API key.
    sops.secrets =
      let
        userOwned = {
          owner = globals.user;
          group = "users";
        };
      in
      {
        google-api-key = userOwned;
        google-cal-id = userOwned;
      };

    # Select the Qtile package.
    services.xserver.windowManager.qtile.package = qtile-package;

    # Enable Qtile.
    services.xserver.enable = true;
    services.xserver.windowManager.qtile.enable =
      assert lib.assertMsg (
        !(config.modules.gui.qtile && config.modules.gui.gnome)
      ) "Multiple desktop managers are not supported.";
      true;

    # Enable the picom compositor.
    # NOTE: does not do anything at the moment.
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };

    # Set up auto login if required.
    services.displayManager.autoLogin = {
      enable = config.modules.boot.autoLogin;
      user = globals.user;
    };

    # Set up lightdm if there is no auto login.
    services.xserver.displayManager.lightdm =
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

    # Systemd service that sends a hook notification to Qtile after a network
    # connection is established. Also send the message after sleeping.
    systemd.services.qtile-network-notification = {

      # Run after a network connection is available.
      preStart = "${pkgs.host}/bin/host google.com";
      wantedBy = [ "default.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      # Send a notification to Qtile that the network connection is established.
      path = [ qtile-package ];
      script = ''
        qtile cmd-obj -o cmd -f fire_user_hook -a network_connected || true
      '';

      serviceConfig = {
        Type = "oneshot";
        User = globals.user;

        # Restart if there is no network connection yet.
        Restart = "on-failure";
        RestartSec = "5sec";
      };
    };
    systemd.services.seafile-daemon-restarter = {

      # Run after resuming from suspend.
      wantedBy = [ "suspend.target" ];
      after = [ "suspend.target" ];

      # Run a command to restart the other service.
      path = [ pkgs.systemd ];
      script = "systemctl --no-block start qtile-network-notification.service";

      serviceConfig.Type = "simple";

    };

    # Start the daemon to handle touchpad gestures.
    systemd.services.libinput-gestures =
      let
        libinput-config-file = pkgs.writers.writeText "libinput-gestures.conf" ''
          gesture swipe left 3 ${qtile-package}/bin/qtile cmd-obj -o screen -f next_group
          gesture swipe right 3 ${qtile-package}/bin/qtile cmd-obj -o screen -f prev_group
          gesture swipe down 3 ${qtile-package}/bin/qtile cmd-obj -o group P -f toscreen
          gesture swipe up 3 ${qtile-package}/bin/qtile cmd-obj -o group U -f toscreen
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
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        # Main Qtile configuration files.
        home.file.".config/qtile" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/qtile";
          recursive = true;
        };

      };

  };
}
