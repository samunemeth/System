# --- Boot ---

{ config, pkgs, lib, globals, ... }:
{

  # Configure bootloader to have a maximum of 30 entries,
  # and a timeout of 1 seconds to allow rollbacks.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 30;
    };
    timeout = lib.mkDefault 1;
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

  # Configure power actions on different events.
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "ignore";
    powerKey = "ignore";
    powerKeyLongPress = "poweroff"; # Does not seem to do anything!
  };

  # Set delay to hibernate after sleeping in the corresponding mode.
  # Your system might have an option to enter a slightly deeper slepp mode.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=10m
    SuspendState=mem
  '';

}
