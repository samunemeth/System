# --- Configuration for Edmund ---

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
      isDesktop = true;
      hibernation = false;
    };

    # Boot options.
    boot = {
      silentBoot = true;
      luksPrompt = false;
      autoLogin = false;
      secureboot = false; # Turn off before first boot!
    };

    # Locale options.
    locale = {
      timeZone = "Europe/Amsterdam";
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
      gnome = true;
      kmscon = true;
      qtile = false;
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
      python = false;
      rust = false;
    };

  };

}
