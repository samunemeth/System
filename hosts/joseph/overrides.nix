# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{


  boot.loader = {
    systemd-boot.configurationLimit = 3;
    timeout = 3;
  };


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  home.file.".config/qtilemachine.py".text = ''

    available_layouts = ["us", "us dvp"]

    has_battery = True
    has_backlight = True

    backlight_name = "amdgpu_bl2"
    processor_temperature_name = "Tctl"

    wireless_interface = "wlp4s0"
    wired_interface = "enp2s0f0"

  '';


  };
}
