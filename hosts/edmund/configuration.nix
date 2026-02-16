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
      hibernation = true;
    };

    # Boot options.
    boot = {
      silentBoot = false;
      luksPrompt = true;
      autoLogin = true;
      secureboot = false; # Turn off before first boot!
    };

    # Locale options.
    locale = {
      timeZone = "Europe/Amsterdam";
      keyboardLayouts = [
        "us"
        "hu"
      ];
      grammar = false;
    };

    # YubiKey options.
    yubikey = {
      enable = false;
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
      manuals = true;
    };

    # Apps to install.
    apps = {
      alacritty = true;
      dmenu = true;
      epy = true;
      firefox = true;
      ipycalc = false;
      lf = true;
      mpv = true;
      neovim = true;
      rofi = true;
      tmux = false;
      vscode = false;
      zathura = true;
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

  # Settings for Nvidia graphics card.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    nvidiaSettings = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

}
