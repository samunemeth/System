# --- Configuration for Edmund ---

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

    # This is a desktop.
    isDesktop = true;

    # It has no encryption.
    boot = {
      silentBoot = true;
      luksPrompt = false;
    };

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "hu"
    ];

    # Enable low priority packages.
    packages.lowPriority = true;

    # Enable Qtile as a window manager.
    kmscon.enable = true;
    qtile = {
      enable = true;
      processorTemperatureName = "Package id 0";
      autoLogin = false;
    };
    gnome.enable = false;

    # Enable latex tools and packages.
    latex.enable = true;

    # Disable tools for programming.
    programming = {
      vscode = false;
      java = false;
      rust = false;
    };

    # Enable support for YubiKeys, logging in and using sudo with them.
    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

    # Enable Seafile file syncing.
    seafile.enable = true;

  };

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      # Change Alacritty font size for 1440p monitor.
      programs.alacritty.settings.font.size = lib.mkForce 12;

    };
}
