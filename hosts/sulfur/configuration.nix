# --- Configuration for Sulfur ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Configuration for modules.
  modules = {

    local.keyboardLayouts = [
      "hu"
      "us"
      "us dvp"
    ];
    qtile.processorTemperatureName = "Package id 0";

    packages = {
      lowPriority = true;
      programming = false;
    };

  };

  # Shorten boot loader timeout as NixOS is not used frequently.
  boot.loader.timeout = 1;

  # Set time zone to CET.
  time.timeZone = "Europe/Budapest";

}
