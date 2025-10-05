# --- Overrides for Sulfur ---

{ config, pkgs, lib, globals, ... }:
{

  # Shorten boot loader timeout as NixOS is not used frequently.  
  boot.loader.timeout = 1;

  # Set time zone to CET.
  time.timeZone = "Europe/Budapest";

  # Qtile settings.
  qtile.availableKeyboardLayouts = ["hu" "us" "us dvp"];
  qtile.processorTemperatureName = "Package id 0";

}
