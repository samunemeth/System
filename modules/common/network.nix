
# --- Template ---

{ config, pkgs, lib, globals, ... }:
{


  # Just a basic host name.
  networking.hostName = lib.mkDefault "nixos";

  # Enable networking with network manager.
  networking.networkmanager.enable = true;

  # Enable the firewall, and do not let anything through.
  networking.firewall.enable = true;

  # Enable Bluetooth on the system.
  hardware.bluetooth.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

}





