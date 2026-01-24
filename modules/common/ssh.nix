# --- SSH ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  sops.secrets =
    let
      userOwned = {
        owner = globals.user;
        group = "users";
      };
    in
    {

      # Request "pass" ssh key from sops, and place them in the default location.
      # NOTE: Create a symlink to these later, as despite being owned by the user,
      # > when placing these files, the parent directory gets owned by root.
      # > Because of this, directly placing them in place is unreliable.
      user-ssh-pass-public = userOwned;
      user-ssh-pass-private = userOwned;

    };

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

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    let
      user-ssh-pass-public-path = config.sops.secrets.user-ssh-pass-public.path;
      user-ssh-pass-private-path = config.sops.secrets.user-ssh-pass-private.path;
    in
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home.file = {

        # Link the "pass" ssh keys into place.
        "/home/${globals.user}/.ssh/id_pass.pub".source =
          config.lib.file.mkOutOfStoreSymlink user-ssh-pass-public-path;
        "/home/${globals.user}/.ssh/id_pass".source =
          config.lib.file.mkOutOfStoreSymlink user-ssh-pass-private-path;

      };


    };

}
