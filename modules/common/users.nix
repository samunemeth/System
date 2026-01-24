# --- Users ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # --- Users ---

  # Setup for getting the user's password hash.
  users.mutableUsers = false;

  # Default User
  sops.secrets.user-password-hash = { };
  sops.secrets.user-password-hash.neededForUsers = true;
  users.users.${globals.user} = {
    isNormalUser = true;
    description = globals.name;
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "audio"
      "input"
    ];
    hashedPasswordFile = config.sops.secrets.user-password-hash.path;
  };

  # Root User
  sops.secrets.root-password-hash = { };
  sops.secrets.root-password-hash.neededForUsers = true;
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-password-hash.path;
  };

  # --- Sudo ---

  # Enable password prompt for sudo.
  # Make it require the root password.
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;

    # Show password hints.
    extraConfig = ''
      Defaults pwfeedback
    '';
  };

  # --- Mounting ---

  # TODO: Add an option for this.

  # Add permission for users to mount storage media.
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var YES = polkit.Result.YES;
      var permission = {
        "org.freedesktop.udisks2.filesystem-mount": YES,
        "org.freedesktop.udisks2.eject-media": YES,
        "org.freedesktop.udisks2.encrypted-unlock": YES,
        "org.freedesktop.udisks2.filesystem-mount-system": YES
      };
      if (subject.isInGroup("wheel")) {
        return permission[action.id];
      }
    });
  '';

  # Enable service for mounting as a user.
  services.udisks2.enable = true;

  # Create a daemon that automatically mounts disks.
  systemd.user.services.udiskie-daemon = {
    description = "udiskie automounter";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.udiskie}/bin/udiskie -a -n -C -F";
      Restart = "always";
    };
  };


}
