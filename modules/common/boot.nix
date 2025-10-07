# --- Boot ---

{ config, pkgs, lib, globals, ... }:
{

  # Configure bootloader to have a maximum of 3 entries,
  # and a timeout of 3 seconds to allow rollbacks.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 3;
    };
    timeout = lib.mkDefault 3;
  };

  # Set boot options to enable resuming from hibernation.
  boot.initrd.systemd.enable = true;

  # Silent boot implementation.
  boot.kernelParams = [ "quiet" "fbcon=vc:2-6" "console=tty0" ];
  boot.consoleLogLevel = 0;

  #boot.plymouth.enable = true;


  # --- Power Management ---


  # Enable power management packages for sleep and hibernation.
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # Enable upower for keeping statistics.
  services.upower.enable = true;

  # Configure power actions on different events.
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "ignore";
    powerKey = "ignore";
    powerKeyLongPress = "hibernate";
  };

  # Set delay to hibernate after sleeping in the corresponding mode.
  # Your system might have an option to enter a slightly deeper sleep mode.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=10m
    SuspendState=mem
  '';

}
