# --- Configuration for Joseph ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Configuration for modules.
  modules = {

    local.keyboardLayouts = [
      "us"
      "us dvp"
    ];
    qtile.processorTemperatureName = "Tctl";

    packages = {
      lowPriority = true;
      programming = true;
      latex = true;
    };

  };

  # This machine has a big battery, so it is fine to stay in sleep longer.
  # Still no deeper sleep state however.
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

}
