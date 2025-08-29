# --- Template ---

{ config, pkgs, lib, globals, ... }:
{


  environment.systemPackages = with pkgs; [

    # lm_sensors           # Read system sensors.
    brightnessctl        # Built in monitor brightness control.
    # acpilight            # Alternative brightness controller.
    pulseaudio-ctl       # Command line volume control.
    hsetroot             # For background setting.

  ];

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  # Link Qtile configuration into place.
  home.file = {
    ".config/qtile" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/qtile";
      recursive = true;
    };
    ".config/qtilemachine.py".text = lib.mkDefault ''
      wireless_interface = "wlo1"
      available_layouts = ["hu", "us", "us dvp"]
    '';
  };



  };
}
