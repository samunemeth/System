# --- Auto Mount ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

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
