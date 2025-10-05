# --- Overrides for Edmund ---

{ config, pkgs, lib, globals, ... }:
{

  # Change systemd console mode to account for large display.
  boot.loader.systemd-boot.consoleMode = "max";

  # Configure keyboard layout.
  local.keyboardLayout = "hu";

  # No touchpad on a desktop.
  systemd.services.libinput-gestures.enable = false;

  # Qtile settings.
  qtile.availableKeyboardLayouts = ["hu" "us"];
  qtile.processorTemperatureName = "Package id 0";


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  # Change Alacritty font size for 1440p monitor.
  programs.alacritty.settings.font.size = lib.mkForce 12;

  };
}
