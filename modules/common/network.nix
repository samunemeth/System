# --- Network ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Define networks present in the secrets.
  # TODO: Somehow make it so we are not depending on this list.
  normal_networks = [
    "HOME"
    "GERARD"
    "HOTSPOT"
  ];
  enterprise_networks = [
    "TUE"
  ];

  # Generate configuration for the specified networks, if secrets are available.
  normal_network_config = (
    builtins.foldl' (
      profiles: id:
      profiles
      // {
        ${id} = {

          connection.id = id;
          wifi.ssid = "\$${id}_SSID";
          wifi-security.key-mgmt = "\$${id}_MGMT";
          wifi-security.psk = "\$${id}_PASS";

          # Generic options that need to be set.
          wifi.mode = "infrastructure";
          wifi-security.auth-alg = "open";
          connection.type = "wifi";

          # Automatic IP address on all networks.
          ipv4.method = "auto";
          ipv6.method = "auto";
          ipv6.addr-gen-mode = "default";

        };
      }
    ) { } normal_networks
  );

  enterprise_network_config = (
    builtins.foldl' (
      profiles: id:
      profiles
      // {
        ${id} = {

          connection.id = id;
          wifi.ssid = "\$${id}_SSID";
          "802-1x".identity = "\$${id}_IDEN";
          "802-1x".password = "\$${id}_PASS";

          # Options for enterprise networks.
          wifi-security.key-mgmt = "wpa-eap";
          "802-1x".eap = "peap";
          "802-1x".phase2-auth = "mschapv2";

          # Generic options that need to be set.
          wifi.mode = "infrastructure";
          connection.type = "wifi";

          # Automatic IP address on all networks.
          ipv4.method = "auto";
          ipv6.method = "auto";
          ipv6.addr-gen-mode = "default";

        };
      }
    ) { } enterprise_networks
  );

in
{

  # Just a basic host name.
  networking.hostName = lib.mkDefault "nixos";

  networking.networkmanager = {

    # Enable networking with network manager.
    enable = true;

    # There are no plugins needed at the moment.
    plugins = lib.mkForce [ ];

    # Enable extra power saving for the network adapter.
    wifi.powersave = true;

  };

  # Enable the firewall, and do not let anything through.
  networking.firewall.enable = true;

  hardware.bluetooth = {

    # Enable Bluetooth on the system.
    enable = true;

    # Turn off Bluetooth by default.
    powerOnBoot = false;

  };

  # --- Declarative WiFi ---

  # Get the environment variables from sops, and add them to the environment.
  sops.secrets.wireless-env = { };
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.sops.secrets.wireless-env.path
  ];

  # Add normal and enterprise networks.
  networking.networkmanager.ensureProfiles.profiles =
    normal_network_config // enterprise_network_config;

}
