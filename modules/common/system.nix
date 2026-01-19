# --- System and Power Management ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For setting the nix path.
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
    system.isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Weather the machine is a desktop machine. If true, disables touch
        input gestures.
      '';
    };
  };

  config = {

    # Set host name default.
    networking.hostName = globals.host;

    # Enable sound with Pulse Audio by default.
    services.pulseaudio.enable = true;
    services.pipewire.enable = false;
    security.rtkit.enable = true;

    # Enable flakes.
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Add nixpkgs to the nix path. This is needed for nixd.
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Write JSON files with the globals and module settings.
    environment.etc."system-options/globals.json".text = builtins.toJSON globals;
    environment.etc."system-options/modules.json".text = builtins.toJSON config.modules;

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

    # Enable power management option for sleep and hibernation.
    powerManagement.enable = true;

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
