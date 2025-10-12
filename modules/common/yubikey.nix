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

  config = lib.mkIf config.modules.yubikey.enable {
    environment.systemPackages = with pkgs; [

      pam_u2f # Enables pam to use u2f authentication.
      yubikey-manager # To manage the YubiKey from the terminal.

    ];

    # Smart card service.
    services.pcscd.enable = true;
    services.yubikey-agent.enable = true;

    # YubiKey for login and sudo.
    security.pam = {
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
  };
}
