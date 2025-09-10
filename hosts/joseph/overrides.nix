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
    wireless_interface = "wlp4s0"
    available_layouts = ["us", "us dvp"]
    #available_layouts = ["us", "us intl", "us dvp"]
    backlight_name = "amdgpu_bl2"
  '';


  };
}
