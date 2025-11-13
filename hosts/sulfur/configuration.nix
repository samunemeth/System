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

    # It has no encryption.
    boot = {
      silentBoot = true;
      luksPrompt = true;
      autoLogin = true;
    };

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "hu"
    ];

    # Enable low priority packages, disable manuals.
    packages = {
      lowPriority = true;
      manuals = false;
    };

    # Enable Qtile as a window manager.
    kmscon.enable = true;
    qtile.enable = true;
    gnome.enable = false;

    # Enable Firefox browser.
    firefox = {
      enable = true;
      tridactyl = false;
    };

    # Disable tools for programming.
    programming = {
      latex = false;
      java = false;
      rust = false;
      python = false;
    };

    # Enable support for YubiKeys, logging in and using sudo with them.
    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

    # Enable Seafile file syncing.
    seafile = {
      enable = true;
      repos = {
        "411830eb-158e-4aa5-9333-869e7dfa7d99" = "Documents";
        "734b3f5b-7bd0-49c2-a1df-65f1cbb201a4" = "Notes";
      };
    };

  };

  # Shorten boot loader timeout as NixOS is not used frequently.
  boot.loader.timeout = 1;

  # Needs different scaling in the boot loader.
  boot.loader.systemd-boot.consoleMode = "keep";

  # Set time zone to CET.
  time.timeZone = "Europe/Budapest";

}
