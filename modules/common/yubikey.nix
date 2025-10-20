# --- YubiKey ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.yubikey.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables YubiKey specific applications and utilities.
      '';
    };
    modules.yubikey.login = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables login with YubiKey.
      '';
    };
    modules.yubikey.sudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables sudo with YubiKey.
      '';
    };
  };

  config = lib.mkIf config.modules.yubikey.enable (
    let

      yubikey-up = pkgs.writers.writeBashBin "yubikey-up" ''
        # ${pkgs.dunst}/bin/dunstify "YubiKey plugged in."
        rm /home/samu/unplugged.tmp
        touch /home/samu/plugged.tmp
      '';

      yubikey-down = pkgs.writers.writeBashBin "yubikey-down" ''

        # sudo -u "samu" env DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus XAUTHORITY=/home/samu/.Xauthority ${pkgs.xsecurelock}/bin/xsecurelock

        rm /home/samu/plugged.tmp
        touch /home/samu/unplugged.tmp

      '';

    in
    {

      environment.systemPackages = lib.flatten [
        (with pkgs; [

          pam_u2f # Enables pam to use u2f authentication.
          yubikey-manager # To manage the YubiKey from the terminal.
          xsecurelock

        ])

        yubikey-up
        yubikey-down

      ];

      # Smart card service.
      services.pcscd.enable = true;
      services.yubikey-agent.enable = true;

      # YubiKey for login and sudo.
      security.pam = {
        sshAgentAuth.enable = true;
        u2f = {
          enable = true;
          settings = {
            cue = true; # Tells user they need to press the button
            authFile = "/home/${globals.user}/.config/Yubico/u2f_keys";
          };
        };
        services = {
          login.u2fAuth = config.modules.yubikey.login;
          sudo.u2fAuth = config.modules.yubikey.sudo;
        };
      };

      # Enable u2f authentication for sudo,
      security.sudo.extraConfig = ''
        Defaults env_keep+=SSH_AUTH_SOCK
      '';

      # Extract u2f keys into correct place.
      sops.secrets.u2f-keys = {
        owner = globals.user;
        group = "users";
        path = "/home/${globals.user}/.config/Yubico/u2f_keys";
      };

      # Add `yubi` ssh keys to the users `.ssh` folder.
      sops.secrets.user-ssh-yubi-public = {
        owner = globals.user;
        group = "users";
        path = "/home/${globals.user}/.ssh/id_yubi.pub";
      };
      sops.secrets.user-ssh-yubi-private = {
        owner = globals.user;
        group = "users";
        path = "/home/${globals.user}/.ssh/id_yubi";
      };

      systemd.services.session-locker = {
        wantedBy = [ "multi-user.target" ];
        after = [ "display-manager.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.xsecurelock}/bin/xsecurelock";
          User = globals.user;
        };
      };

      services.udev.enable = true;
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
        SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
      '';

      # --- Home Manager Part ---
      home-manager.users.${globals.user} =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        {

          # Touch detection
          # home.packages = with pkgs; [
          #   yubikey-touch-detector
          #   gnupg
          # ];
          #
          # systemd.user.sockets.yubikey-touch-detector = {
          #   Unit.Description = "Unix socket activation for YubiKey touch detector service";
          #   Socket = {
          #     ListenFIFO = "%t/yubikey-touch-detector.sock";
          #     RemoveOnStop = true;
          #     SocketMode = "0660";
          #   };
          #   Install.WantedBy = [ "sockets.target" ];
          # };
          #
          # systemd.user.services.yubikey-touch-detector = {
          #   Unit = {
          #     Description = "Detects when your YubiKey is waiting for a touch";
          #     Requires = [ "yubikey-touch-detector.socket" ];
          #   };
          #   Service = {
          #     ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --libnotify";
          #     Environment = [ "PATH=${lib.makeBinPath [ pkgs.gnupg ]}" ];
          #     Restart = "on-failure";
          #     RestartSec = "1sec";
          #   };
          #   Install.Also = [ "yubikey-touch-detector.socket" ];
          #   Install.WantedBy = [ "default.target" ];
          # };
        };
    }
  );
}
