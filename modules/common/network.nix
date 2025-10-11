# --- Template ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let
in
{

  # Just a basic host name.
  networking.hostName = lib.mkDefault "nixos";

  # Enable networking with network manager.
  networking.networkmanager = {
    enable = true;
    plugins = lib.mkForce [ ];
  };

  # Enable the firewall, and do not let anything through.
  networking.firewall.enable = true;

  # Enable Bluetooth on the system.
  hardware.bluetooth.enable = true;

  # --- Declarative WiFi ---

  # Get the environment variables from sops, and add them to the environment.
  sops.secrets.wireless-env = { };
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.sops.secrets.wireless-env.path
  ];

  # Add the profiles that are declared at the end form the sops file.
  networking.networkmanager.ensureProfiles.profiles =
    builtins.foldl'
      (
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
      )
      { }
      [
        "HOME"
        "GERARD"
        "HOTSPOT"
      ];

}
