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

  qtile-wayland-session = pkgs.writeTextFile {
    name = "qtile-wayland-session";
    destination = "/share/wayland-sessions/qtile-wayland.desktop";
    passthru.providedSessions = [ "qtile-wayland" ];
    text = ''
      [Desktop Entry]
      Name=Qtile Wayland
      Comment=Custom Qtile Wayland Session
      Exec=${qtile-package}/bin/qtile start -l ${qtile-log-level} -c /etc/xdg/qtile/config.nix -b wayland
      Type=Application
      Keywords=wm;tiling
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

    # BUG: Clipboard is completely fucked.
    # BUG: Numlock is not turned on by default.
    # TODO: Check if there are ways to reduce Wayland power usage even more.

    # Packages related to Qtile in some way.
    environment.systemPackages =
      with pkgs;
      [

        lm_sensors # Read system sensors.
        acpilight # Brightness controller.
        pulseaudio-ctl # Command line volume control.
        swaybg # For background setting.
        # BUG: No notifications are showing up.
        libnotify # Notification handling library.
        dunst # Notification daemon.

      ]
      # TODO: Handle errors if these are missing.
      ++ lib.lists.optionals config.modules.packages.lowPriority [

        playerctl # For media control (play/pause).
        # BUG: Seems to produce black images.
        scrot # For screenshots.
        # BUG: Does not work on Wayland of course.
        xcolor # For color picking.
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

    # Add configuration files to correct directory.
    environment.etc."xdg/qtile".source = "${qtile-home}/qtile";

    # Enable Qtile. Use the custom session instead of the usual option.
    services.displayManager.sessionPackages = [ qtile-wayland-session ];

    # Set up display manager and auto login.
    services.displayManager = {
      defaultSession = "qtile-wayland";
      autoLogin = {
        enable = true;
        user = globals.user;
      };

      # TODO: Remove sddm if possible.
      sddm = {
        enable = true;
        wayland.enable = true;
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

  };
}
