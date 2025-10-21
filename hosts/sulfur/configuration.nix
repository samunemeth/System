# --- Configuration for Sulfur ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Configuration for custom modules.
  modules = {

    # This is a laptop.
    isDesktop = false;

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "hu"
      "us dvp"
    ];

    # Enable low priority packages.
    packages.lowPriority = true;

    # Enable Qtile as a window manager.
    kmscon.enable = true;
    qtile = {
      enable = true;
      processorTemperatureName = "Package id 0";
    };
    gnome.enable = false;

    # Disable latex tools and packages.
    latex.enable = false;

    # Disable tools for programming.
    programming = {
      vscode = false;
      java = false;
    };

    # Enable support for YubiKeys, logging in and using sudo with them.
    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

  };

  # Shorten boot loader timeout as NixOS is not used frequently.
  boot.loader.timeout = 1;

  # Set time zone to CET.
  time.timeZone = "Europe/Budapest";

}
