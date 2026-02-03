# --- Configuration for Joseph ---

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
      secureboot = true; # Turn off before first boot!
    };

    # Locale options.
    locale = {
      timeZone = "Europe/Amsterdam";
      keyboardLayouts = [ "us" ];
      grammar = false;
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
      kmscon = true;
      qtile = true;
    };

    # General package options.
    packages = {
      lowPriority = true;
      manuals = true;
    };

    # Apps to install.
    apps = {
      alacritty = true;
      epy = true;
      firefox = true;
      ipycalc = true;
      lf = true;
      mpv = true;
      rofi = true;
      neovim = true;
      vscode = false;
    };

    # Programming languages to install.
    code = {
      bash = true;
      haskell = true;
      java = false;
      julia = false;
      latex = true;
      lua = true;
      nix = true;
      python = true;
      rust = false;
    };

  };

  # Only enable integrated graphics, as it suffices for most tasks, and has
  # greatly reduced power usage.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

}
