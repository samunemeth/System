# --- Configuration for Minima ---

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
      silentBoot = false;
      luksPrompt = false;
      autoLogin = true;
      secureboot = false; # Turn off before first boot!
    };

    # Locale options.
    locale = {
      timeZone = "Etc/Universal";
      keyboardLayouts = [ "us" ];
    };

    # YubiKey options.
    yubikey = {
      enable = false;
      login = false;
      sudo = false;
      ssh = false;
    };

    # File options.
    seafile.enable = false;
    copyparty.enable = false;

    # GUIs to install and use.
    gui = {
      gnome = false;
      kmscon = true;
      qtile = false;
    };

    # General package options.
    packages = {
      lowPriority = false;
      manuals = false;
    };

    # Apps to install.
    apps = {
      alacritty = false;
      dmenu = false;
      epy = false;
      firefox = false;
      ipycalc = false;
      lf = true;
      mpv = false;
      neovim = false;
      rofi = false;
      tmux = true;
      vscode = false;
      zathura = false;
    };

    # Programming languages to install.
    code = {
      bash = false;
      haskell = false;
      java = false;
      julia = false;
      latex = false;
      lua = false;
      nix = false;
      python = false;
      rust = false;
    };

  };

  services.fprintd.enable = lib.mkForce false;
  services.keyd.enable = lib.mkForce false;
  networking.networkmanager.enable = lib.mkForce false;
  services.udisks2.enable = lib.mkForce false;

}
