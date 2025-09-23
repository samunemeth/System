# --- Overrides for Edmund ---

{ config, pkgs, lib, globals, ... }:
{

  # Change systemd console mode to account for large display.
  boot.loader.systemd-boot.consoleMode = "max";

  # Configure keyboard layout.
  local.keyboardLayout = "hu";

  # No touchpad on a desktop.
  systemd.services.libinput-gestures.enable = false;

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  home.file.".config/qtilemachine.py".text = ''

    available_layouts = ["hu", "us"]

    has_battery = False
    has_backlight = False

    backlight_name = ""
    processor_temperature_name = "Package id 0"

    wireless_interface = "wlo1"
    wired_interface = "enp6s0"

  '';

  # Change Alacritty font size for 1440p monitor.
  programs.alacritty.settings.font.size = lib.mkForce 12;

  };
}
