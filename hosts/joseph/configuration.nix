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

    # Boot options
    boot = {
      silentBoot = true;
      luksPrompt = true;
      autoLogin = true;
    };

    local.keyboardLayouts = [
      "us"
      "us dvp"
    ];

    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

    seafile = {
      enable = true;
      repos = {
        "411830eb-158e-4aa5-9333-869e7dfa7d99" = "Documents";
        "734b3f5b-7bd0-49c2-a1df-65f1cbb201a4" = "Notes";
      };
    };

    # Enable Qtile as a window manager.
    kmscon.enable = false;
    qtile.enable = true;
    gnome.enable = false;

    # Settings for general packages.
    packages = {
      lowPriority = true;
      manuals = true;
    };

    # Apps to install.
    apps = {
      alacritty = true;
      lf = true;
      firefox = true;
      mpv = true;
    };

    # Programming languages to install.
    code = {
      latex = true;
      java = false;
      rust = false;
      python = true;
    };

  };

  # Only enable integrated graphics, as it suffices for most tasks, and has
  # greatly reduced power usage.
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

}
