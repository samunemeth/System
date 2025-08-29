# --- Overrides for Sulfur ---

{ config, pkgs, lib, globals, ... }:
{


  # Configure keyboard layout.
  services.xserver.xkb = {
    layout = "hu";
    variant = "";
  };
  console.keyMap = "hu";


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  home.file.".config/qtilemachine.py".text = ''
    wireless_interface = "wlo1"
    available_layouts = ["hu", "us", "us dvp"]
  '';


  };
}
