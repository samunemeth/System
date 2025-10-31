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
    };

    # Configure keyboard layouts. The first one becomes the default.
    local.keyboardLayouts = [
      "us"
      "us dvp"
    ];

    # Enable low priority packages.
    packages.lowPriority = true;

    # Enable Qtile as a window manager.
    kmscon.enable = true;
    qtile = {
      enable = true;
      processorTemperatureName = "Tctl";
      autoLogin = true;
    };
    gnome.enable = false;

    # Enable latex tools and packages.
    latex.enable = true;

    # Enable tools for programming.
    programming = {
      vscode = true;
      java = true;
      rust = true;
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

  # This machine has a big battery, so it is fine to stay in sleep longer.
  # Still no deeper sleep state however.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

}
