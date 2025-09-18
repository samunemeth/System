# --- Overrides for Sulfur ---

{ config, pkgs, lib, globals, ... }:
{


  # Configure keyboard layout.
  services.xserver.xkb = {
    layout = "hu";
    variant = "";
  };
  console.keyMap = "hu";

  
  boot.loader = {
    systemd-boot.configurationLimit = 3;
    timeout = 1;
  };


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  home.file.".config/qtilemachine.py".text = ''

    available_layouts = ["hu", "us", "us dvp"]

    has_battery = True
    has_backlight = True

    backlight_name = "intel_backlight"
    processor_temperature_name = "Package id 0"

    wireless_interface = "wlo1"
    wired_interface = "eth0"

  '';


  };
}
