{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.copyparty.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enables the copyparty rclone mount.
      '';
    };
  };

  config = lib.mkIf config.modules.copyparty.enable {

    # Request secrets for Copyparty.
    sops.secrets.copyparty-url = {
      owner = globals.user;
      group = "users";
    };
    sops.secrets.copyparty-user = { };
    sops.secrets.copyparty-pass = { };

    # Ensure fuse is set up for allow_other if needed
    environment.etc."fuse.conf".text = ''
      user_allow_other
    '';

    systemd.services.copyparty-mount = {

      # Check for a network connection by trying to resolve google.com
      preStart = "${pkgs.host}/bin/host google.com";

      # Run after a network connection is available.
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      # Add packages to path.
      path = [
        pkgs.host
        pkgs.rclone
      ];

      # Script for running Copyparty.
      script = ''

        # Create the target mounting directory.
        mkdir -p /copyparty

        # Create a configuration directory that is only available as root.
        mkdir -p /run/copyparty
        chmod 700 /run/copyparty

        # Get the needed credentials.
        remoteurl=$(< ${config.sops.secrets.copyparty-url.path})
        remoteuser=$(< ${config.sops.secrets.copyparty-user.path})
        remotepass=$(< ${config.sops.secrets.copyparty-pass.path})

        export RCLONE_CONFIG=/run/copyparty/rclone.conf
        rclone config create homeserver-dav webdav \
          url="$remoteurl" \
          vendor="owncloud" \
          pacer_min_sleep="0.01ms" \
          user="$remoteuser" \
          pass="$remotepass" \
          --non-interactive

        rclone mount homeserver-dav: /copyparty \
          --config /run/copyparty/rclone.conf \
          --vfs-cache-mode writes \
          --dir-cache-time 5s \
          --allow-other
          --uid $(id -u ${globals.user}) \
          --gid $(id -g ${globals.user})
      '';

      # Script for cleaning up.
      serviceConfig.ExecStop = "/run/wrappers/bin/fusermount -u /copyparty";

      serviceConfig = {
        Type = "simple";
        User = "root";

        # Restart if there is no connection yet.
        Restart = "on-failure";
        RestartSec = "10s";
      };

    };
  };
}
