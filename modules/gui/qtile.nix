# --- Qtile ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For building Qtile directly from the flake.
  ...
}:
let

  qtile-log-level = "INFO";
  qtile-package = inputs.qtile-flake.packages.${globals.system}.default.overrideAttrs (oldAttrs: {
    dontUsePytestCheck = true;
  });

  qtile-home = pkgs.stdenvNoCC.mkDerivation {
    name = "qtile-home";
    src = ../../src/qtile;
    installPhase = ''
      mkdir -p $out/qtile
      cp -r * $out/qtile/
    '';
  };

  qtile-session-x11 = pkgs.writeTextFile {
    name = "qtile-custom-session";
    destination = "/share/xsessions/qtile.desktop";
    passthru.providedSessions = [ "qtile" ];
    text = ''
      [Desktop Entry]
      Name=Qtile
      Comment=Custom Qtile Session
      Exec=${qtile-package}/bin/qtile start -l ${qtile-log-level} -c /etc/xdg/qtile/config.nix
      Type=Application
      Keywords=wm;tiling
    '';
  };

  screenshot-script = pkgs.writers.writeBashBin "screenshot" ''
    mkdir -p ~/Screenshots
    ${pkgs.scrot}/bin/scrot ~/Screenshots/screenshot-%Y-%m-%d-%H%M%S.png \
      -e '${pkgs.xclip}/bin/xclip -selection clipboard -target image/png $f'
    ${pkgs.libnotify}/bin/notify-send -u low "Screenshot saved and copied to clipboard."
  '';

  color-picker-script = pkgs.writers.writeBashBin "color-picker" ''
    ${pkgs.xcolor}/bin/xcolor | ${pkgs.xclip}/bin/xclip -selection clipboard
    ${pkgs.libnotify}/bin/notify-send -u low "Copied hex code to clipboard."
  '';

  slock-package = pkgs.slock.override {
    conf = ''
      /* user and group to drop privileges to */
      static const char *user  = "nobody";
      static const char *group = "nogroup";

      static const char *colorname[NUMCOLS] = {
      	[INIT] =   "${globals.colors.background.main}",  /* after initialization */
      	[INPUT] =  "${globals.colors.background.soft}",  /* during input */
      	[FAILED] = "${globals.colors.foreground.error}", /* wrong password */
      };

      /* treat a cleared input like a wrong password (color) */
      static const int failonclear = 0;
    '';
  };

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

    warnings = lib.optional (!config.modules.boot.autoLogin) ''
      Qtile no longer has an option for manual login.
      Auto login will be used despite modules.boot.autoLogin being false.
    '';

    # Packages related to Qtile in some way.
    environment.systemPackages =
      with pkgs;
      [

        screenshot-script
        color-picker-script

        lm_sensors # Read system sensors.
        acpilight # Brightness controller.
        pulseaudio-ctl # Command line volume control.
        hsetroot # For background setting.
        libnotify # Notification handling library.
        dunst # Notification daemon.
        xss-lock # Locking daemon.

      ]
      # TODO: Handle errors if these are missing.
      ++ lib.lists.optionals config.modules.packages.lowPriority [

        numlockx # To enable NumLock by default.
        warpd # Keyboard mouse control and movement emulation.
        playerctl # For media control (play/pause).
        bluetui # For Bluetooth settings.

      ];

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

    # Enable Qtile. Use the custom session instead of the usual option.
    services.xserver.enable = true;
    services.displayManager.sessionPackages = [ qtile-session-x11 ];

    # Add configuration files to correct directory.
    environment.etc."xdg/qtile".source = "${qtile-home}/qtile";

    # Set up auto login.
    services.displayManager.autoLogin = {
      enable = true;
      user = globals.user;
    };
    # TODO: Remove the dependence on lightdm.
    services.xserver.displayManager.lightdm = {
      enable = true;
      greeter.enable = false;
      autoLogin.timeout = 0;
    };

    # Set up locking.
    programs.slock = {
      enable = true;
      package = slock-package;
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
    systemd.services.qtile-network-notification =
      let
        targetList = [
          "suspend.target"
          "hibernate.target"
          "hybrid-sleep.target"
          "suspend-then-hibernate.target"
        ];
      in
      {

        # Run after a network connection is available.
        preStart = "${pkgs.host}/bin/host google.com";
        wantedBy = targetList ++ [ "default.target" ];
        after = targetList ++ [ "network-online.target" ];
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

    # Start the daemon to handle touchpad gestures.
    systemd.user.services.libinput-gestures =
      let
        libinput-config-file = pkgs.writers.writeText "libinput-gestures.conf" ''
          gesture swipe left 3 ${qtile-package}/bin/qtile cmd-obj -o screen -f next_group
          gesture swipe right 3 ${qtile-package}/bin/qtile cmd-obj -o screen -f prev_group
          gesture swipe down 3 ${qtile-package}/bin/qtile cmd-obj -o group P -f toscreen
          gesture swipe up 3 ${qtile-package}/bin/qtile cmd-obj -o group U -f toscreen
          gesture pinch in 2 ${screenshot-script}/bin/screenshot
          gesture pinch out 2 xdotool key ctrl+v
        '';
      in
      {
        enable = lib.mkDefault (if config.modules.system.isDesktop then false else true);
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures -c ${libinput-config-file}";
        };
      };

  };
}
