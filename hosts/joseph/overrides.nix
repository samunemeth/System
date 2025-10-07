# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{

  qtile.availableKeyboardLayouts = ["us" "us dvp"];
  qtile.processorTemperatureName = "Tctl";

  modules.lowPriorityPackages = true;

  # This machine has a big battery, so it is fine to stay in sleep longer.
  # Still no deeper sleep state however.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  # specialisation.lite.configuration = {
  #
  #   services.xserver.enable = lib.mkForce false;
  #   services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  #   services.picom.enable = lib.mkForce false;
  #   services.xserver.windowManager.qtile.enable = lib.mkForce false;
  #   systemd.services.libinput-gestures.enable = lib.mkForce false;
  #
  #   services.kmscon = {
  #     enable = true;
  #     fonts = [{
  #       name = "Hack Nerd Font Mono";
  #       package = pkgs.nerd-fonts.hack;
  #     }];
  #     # hwRender = true;
  #     # useXkbConfig = true;
  #     extraConfig = "login=/bin/bash -i";
  #
  #     # extraOptions =
  #     #   "--palette custom " +
  #     #   "--palette-red=172, 66, 66 " +
  #     #   "--palette-light-red=172, 66, 66 " +
  #     #   "--palette-green=144, 169, 89 " +
  #     #   "--palette-light-green=144, 169, 89 " +
  #     #   "--palette-yellow=24, 191, 117 " +
  #     #   "--palette-light-yellow=24, 191, 117 " +
  #     #   "--palette-blue=106, 159, 181 " +
  #     #   "--palette-light-blue=106, 159, 181 " +
  #     #   "--palette-magenta=170, 117, 159 " +
  #     #   "--palette-light-magenta=170, 117, 159 " +
  #     #   "--palette-cyan=117, 181, 170 " +
  #     #   "--palette-light-cyan=117, 181, 170 " +
  #     #   "--palette-black=20, 22, 27 " +
  #     #   "--palette-background=20, 22, 27 " +
  #     #   "--palette-dark-grey=100, 100, 100 " +
  #     #   "--palette-white=242, 244, 243 " +
  #     #   "--palette-foreground=242, 244, 243 " +
  #     #   "--palette-light-grey= 200, 200, 200 ";
  #   };
  #
  #   boot.kernelParams = lib.mkForce [];
  #
  # };

}
