# --- Configuration for Joseph ---

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

    # It has luks encryption.
    boot = {
      silentBoot = true;
      luksPrompt = true;
      autoLogin = true;
    };
    system.hibernation = false;

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "us dvp"
    ];

    # Enable low priority packages and manuals.
    packages = {
      lowPriority = true;
      manuals = true;
    };

    # Enable Qtile as a window manager.
    kmscon.enable = false;
    qtile.enable = true;
    gnome.enable = false;

    # Enable Firefox browser.
    firefox = {
      enable = true;
      tridactyl = false;
    };

    # Apps to install.
    apps = {
      mpv = true;
      lf = true;
    };

    # Programming languages to install.
    code = {
      latex = true;
      java = false;
      rust = false;
      python = true;
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

  # Only enable integrated graphics, as it suffices for most tasks, and has
  # greatly reduced power usage.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

}
