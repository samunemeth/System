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
      login = false;
      sudo = false;
      ssh = false;
    };

    # File options.
    seafile = {
      enable = true;
      repos = {
        "411830eb-158e-4aa5-9333-869e7dfa7d99" = "Documents";
        "734b3f5b-7bd0-49c2-a1df-65f1cbb201a4" = "Notes";
      };
    };
    copyparty.enable = true;

    # GUIs to install and use.
    gui = {
      gnome = false;
      kmscon = false;
      qtile = true;
    };

    # General package options.
    packages = {
      lowPriority = true;
      manuals = false;
    };

    # Apps to install.
    apps = {
      alacritty = true;
      firefox = true;
      ipycalc = false;
      lf = true;
      mpv = true;
      neovim = true;
      vscode = false;
    };

    # Programming languages to install.
    code = {
      bash = true;
      haskell = false;
      java = false;
      julia = false;
      latex = false;
      lua = true;
      nix = true;
      python = true;
      rust = false;
    };

  };

  # Needs different scaling in the boot loader.
  boot.loader.systemd-boot.consoleMode = "keep";

  # Only enable integrated graphics, as it suffices for most tasks, and has
  # greatly reduced power usage.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "modesetting" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

}
