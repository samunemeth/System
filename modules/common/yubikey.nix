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
      default = false;
      example = true;
      description = ''
        Enables sudo with YubiKey.
      '';
    };
    modules.yubikey.ssh = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables ssh with YubiKey.
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

    # Request u2f keys.
    sops.secrets.u2f-keys = {
      owner = globals.user;
      group = "users";
    };

    # Request the "yubi" ssh key from nix if ssh is enabled.
    # Similar to what happens in `ssh.nix` with "pass".
    sops.secrets.user-ssh-yubi-public = lib.mkIf config.modules.yubikey.ssh {
      owner = globals.user;
      group = "users";
    };
    sops.secrets.user-ssh-yubi-private = lib.mkIf config.modules.yubikey.ssh {
      owner = globals.user;
      group = "users";
    };

    # YubiKey for login and sudo.
    security.pam = {
      sshAgentAuth.enable = config.modules.yubikey.ssh;
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
    security.sudo.extraConfig = lib.mkIf config.modules.yubikey.sudo ''
      Defaults env_keep+=SSH_AUTH_SOCK
    '';

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      let
        user-ssh-yubi-public-path = config.sops.secrets.user-ssh-yubi-public.path;
        user-ssh-yubi-private-path = config.sops.secrets.user-ssh-yubi-private.path;
        u2f-keys-path = config.sops.secrets.u2f-keys.path;
        has-ssh = config.modules.yubikey.ssh;
      in
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        home.file =
          lib.mkAlwaysThenIf has-ssh
            {

              # Link u2f keys into place.
              "/home/${globals.user}/.config/Yubico/u2f_keys".source =
                config.lib.file.mkOutOfStoreSymlink u2f-keys-path;

            }

            {

              # Link the "yubi" ssh keys into place only if ssh is enabled.
              "/home/${globals.user}/.ssh/id_yubi.pub".source =
                config.lib.file.mkOutOfStoreSymlink user-ssh-yubi-public-path;
              "/home/${globals.user}/.ssh/id_yubi".source =
                config.lib.file.mkOutOfStoreSymlink user-ssh-yubi-private-path;

            };

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
