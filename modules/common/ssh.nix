# --- Ssh ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Request "pass" ssh key from sops, and place them in the user ssh folder.
  sops.secrets = {
    user-ssh-pass-public = {
      owner = globals.user;
      group = "users";
      path = "/home/${globals.user}/.ssh/id_pass.pub";
    };
    user-ssh-pass-private = {
      owner = globals.user;
      group = "users";
      path = "/home/${globals.user}/.ssh/id_pass";
    };
  };

  # Make sure that `.ssh` folder is owned by the user.
  system.activationScripts.user-ssh-pass.text = ''
    chown ${globals.user}:users /home/${globals.user}/.ssh
  '';

  # Fixes a conflict with the ssh agent.
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

  # Machine ssh settings.
  programs.ssh = {

    # This is required for YubiKey related stuff.
    startAgent = true;

    # Add extra configuration.
    extraConfig = ''
      Host *
        IdentityFile ~/.ssh/id_yubi
        IdentityFile ~/.ssh/id_pass
        AddKeysToAgent yes
        LogLevel ERROR
    '';

  };

}
