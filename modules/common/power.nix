# --- Power Management ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    system.hibernation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Allows the machine to hibernate.
      '';
    };
  };

  config = {

    # Enable power management for sleep and hibernation.
    powerManagement.enable = true;

    # Enable power saving mode for the CPU.
    # NOTE: This already seems to be the default value.
    powerManagement.cpuFreqGovernor = "powersave";

    # Enable automatic power tuning. Add package to path if already installed.
    powerManagement.powertop.enable = true;
    environment.systemPackages = [ pkgs.powertop ];

    # Enable power management support via Upower.
    services.upower = {
      enable = true;

      # Do not interfere when battery is low.
      criticalPowerAction = "Ignore";
      allowRiskyCriticalPowerAction = true;

    };

    services.logind.settings.Login =

      # Assert that if hibernation is allowed, there has to be a swap device.
      assert lib.assertMsg (
        !(config.modules.system.hibernation) || (lib.lists.length config.swapDevices != 0)
      ) "Hibernation without a swap device is not possible.";

      # Configure power actions on different events.
      {
        HandleLidSwitch = if config.modules.system.hibernation then "suspend-then-hibernate" else "suspend";
        HandleLidSwitchExternalPower = "ignore";
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "poweroff";
      };

    systemd.sleep.extraConfig = (

      # NOTE: Your system might have an option to enter a deeper sleep mode.
      ''
        HibernateDelaySec=10m
        SuspendState=mem
      ''

      # Disable hibernation if not enabled explicitly.
      + lib.strings.optionalString (!config.modules.system.hibernation) ''
        AllowHibernation=no
        AllowSuspendThenHibernate=no
      ''
    );

  };
}
