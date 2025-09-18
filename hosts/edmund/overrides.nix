# --- Overrides for Edmund ---

{ config, pkgs, lib, globals, ... }:
{

  boot.loader = {
    systemd-boot.configurationLimit = 3;
    timeout = 3;
  };

  # Configure keyboard layout.
  services.xserver.xkb = {
    layout = "hu";
    variant = "";
  };
  console.keyMap = "hu";

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


  };
}
