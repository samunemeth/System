# --- Syncthing ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.syncthing.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Syncthing.
      '';
    };
  };

  config = lib.mkIf config.modules.syncthing.enable {

    # Request the secrets related to this machine.
    sops.secrets =
      let

        # The names of the hosts that have an id in the secrets file.
        syncthingHosts = [
          "joseph"
          "edmund-windows"
        ];

        # Default permissions for requested secrets.
        userOwned = {
          owner = globals.user;
          group = "users";
        };

        # Build and attribute set that contains only machines different from
        # this machine, and set the secret to user owned.
        differentSyncthingHosts = throw (builtins.filter (elem: elem != globals.host) syncthingHosts);
        requestIds = builtins.foldl' (
          acc: elem: { "syncthing/${elem}/id" = userOwned; } // acc
        ) { } differentSyncthingHosts;

      in
      (
        {
          # Request the keys for this machine.
          "syncthing/${globals.host}/cert" = userOwned;
          "syncthing/${globals.host}/key" = userOwned;
        }
        # Request ids of other machines.
        // requestIds
      );

    services.syncthing = {

      enable = true;

      # Run as the default user.
      group = "users";
      user = globals.user;

      # TODO: Are these the best spots?
      dataDir = "/home/${globals.user}/Syncthing";
      configDir = "/home/${globals.user}/.config/syncthing";

      # Open port for syncing and discovery.
      openDefaultPorts = true;

      # Remove any imperative configuration.
      overrideFolders = true;
      overrideDevices = true;

      # Set the identity of the machine declaratively.
      cert = config.sops.secrets."syncthing/${globals.host}/cert".path;
      key = config.sops.secrets."syncthing/${globals.host}/key".path;

      # Declarative settings.
      settings = {

        # Enable relays, and disable usage data reporting.
        options = {
          relaysEnabled = true;
          urAccepted = -1;
        };

        devices = { };
        folders = { };
      };
    };

  };
}
