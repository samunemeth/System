# --- Overrides for Sulfur ---

{ config, pkgs, lib, globals, ... }:
{

  # Configure keyboard layout.
  local.keyboardLayout = "hu";

  # Shorten boot loader timeout as NixOS is not used frequently.  
  boot.loader.timeout = 1;

  # Qtile settings.
  qtile.availableKeyboardLayouts = ["hu" "us" "us dvp"];
  qtile.processorTemperatureName = "Package id 0";

}
