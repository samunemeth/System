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

  services.xserver.displayManager.lightdm.greeters.mini.enable = lib.mkForce false;

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  home.file.".config/qtilemachine.py".text = ''

    available_layouts = ["hu"]

    backlight_name = "amdgpu_bl2"
    processor_temperature_name = "Tctl"

    wireless_interface = "wlp4s0"
    wired_interface = "enp2s0f0"

  '';


  };
}
