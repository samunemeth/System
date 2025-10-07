# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{

  qtile.availableKeyboardLayouts = ["us" "us dvp"];
  qtile.processorTemperatureName = "Tctl";

  modules.packages.lowPriority = true;
  modules.packages.programming = true;

  # This machine has a big battery, so it is fine to stay in sleep longer.
  # Still no deeper sleep state however.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

}
