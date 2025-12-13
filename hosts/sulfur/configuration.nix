# --- Configuration for Sulfur ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # High-level modularised configuration.
  modules = {

    # System options.
    system = {
      isDesktop = false;
      hibernation = false;
    };

    # Boot options.
    boot = {
      silentBoot = true;
      luksPrompt = true;
      autoLogin = true;
      secureboot = false; # Turn off before first boot!
    };

    # Locale options.
    locale = {
      timeZone = "Europe/Budapest";
      keyboardLayouts = [
        "us"
        "hu"
      ];
    };

    # YubiKey options.
    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

    # Seafile options.
    seafile = {
      enable = true;
      repos = {
        "411830eb-158e-4aa5-9333-869e7dfa7d99" = "Documents";
        "734b3f5b-7bd0-49c2-a1df-65f1cbb201a4" = "Notes";
      };
    };

    # GUIs to install and use.
    gui = {
      kmscon = true;
      qtile = true;
      gnome = false;
    };

    # General package options.
    packages = {
      lowPriority = true;
      manuals = false;
    };

    # Apps to install.
    apps = {
      alacritty = true;
      lf = true;
      firefox = true;
      mpv = true;
      vscode = false;
      ipycalc = false;
    };

    # Programming languages to install.
    code = {
      latex = false;
      java = false;
      rust = false;
      python = false;
      julia = false;
      haskell = false;
    };

  };

  # Shorten boot loader timeout as NixOS is not used frequently.
  boot.loader.timeout = 1;

  # Needs different scaling in the boot loader.
  boot.loader.systemd-boot.consoleMode = "keep";

}
