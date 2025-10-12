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

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "us dvp"
    ];

    # Enable low priority packages.
    packages.lowPriority = true;

    # Enable Qtile as a window manager.
    qtile = {
      enable = true;
      processorTemperatureName = "Tctl";
    };
    gnome.enable = false;

    # Enable latex tools and packages.
    latex.enable = true;

    # Enable tools for programming.
    programming = {
      vscode = true;
      java = true;
    };

    # Enable support for YubiKeys, logging in and using sudo with them.
    yubikey = {
      enable = true;
      login = true;
      sudo = true;
    };

  };

  # This machine has a big battery, so it is fine to stay in sleep longer.
  # Still no deeper sleep state however.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

}
