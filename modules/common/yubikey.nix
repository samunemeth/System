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

    # TODO: Handle the options a bit cleaner.

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
      path = "/home/${globals.user}/.config/Yubico/u2f_keys";
    };

    # Make sure that this folder is owned by the user.
    system.activationScripts.u2f-keys.text = ''
      chown ${globals.user}:users /home/${globals.user}/.config
      chown ${globals.user}:users /home/${globals.user}/.config/Yubico
    '';

    # Request ssh keys if needed.
    sops.secrets.user-ssh-yubi-public = lib.mkIf config.modules.yubikey.ssh {
      owner = globals.user;
      group = "users";
      path = "/home/${globals.user}/.ssh/id_yubi.pub";
    };
    sops.secrets.user-ssh-yubi-private = lib.mkIf config.modules.yubikey.ssh {
      owner = globals.user;
      group = "users";
      path = "/home/${globals.user}/.ssh/id_yubi";
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

  };
}
