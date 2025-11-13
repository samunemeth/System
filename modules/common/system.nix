# --- System ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    # TODO: Affect the actual ability of hibernation.
    modules.system.hibernation = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Allows the machine to hibernate.
      '';
    };
  };

  config = {

    # Set host name default.
    networking.hostName = globals.host;

    # Enable flakes.
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Set state versions.
    system.stateVersion = globals.stateVersion;
    home-manager.users.${globals.user}.home.stateVersion = globals.stateVersion;

    # Allow unfree packages.
    nixpkgs = {
      system = globals.system;
      config.allowUnfree = true;
    };

    # Automatically optimise packages.
    nix.settings.auto-optimise-store = true;

    # Automatically collect garbage.
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };

    # --- Power Management ---

    # Enable power management packages for sleep and hibernation.
    # Upower for keeping battery statistics, but only on laptops.
    powerManagement.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = !config.modules.isDesktop;

    services.logind =

      # Assert that if hibernation is allowed, there has to be a swap device.
      assert lib.assertMsg (
        !(config.modules.system.hibernation) || (lib.lists.length config.swapDevices != 0)
      ) "Hibernation without a swap device is not possible.";

      # Configure power actions on different events.
      {
        lidSwitch = if config.modules.system.hibernation then "suspend-then-hibernate" else "suspend";
        lidSwitchExternalPower = "ignore";
        powerKey = "ignore";
        powerKeyLongPress = "poweroff";
      };

    # Set delay to hibernate after sleeping in the corresponding mode.
    # Your system might have an option to enter a slightly deeper sleep mode.
    systemd.sleep.extraConfig = ''
      HibernateDelaySec=10m
      SuspendState=mem
    '';

  };
}
