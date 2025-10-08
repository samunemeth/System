# --- Configuration for Edmund ---

{ config, pkgs, lib, globals, ... }:
{

  # Configuration for modules.
  modules = {

    local.keyboardLayouts = ["hu" "us"];
    qtile.processorTemperatureName = "Package id 0";

    packages = {
      lowPriority = true;
      programming = false;
    };

  };

  # Change systemd console mode to account for large display.
  boot.loader.systemd-boot.consoleMode = "max";

  # No touchpad on a desktop.
  systemd.services.libinput-gestures.enable = false;

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
