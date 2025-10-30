# --- Boot ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.boot.silentBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Silences the boot sequence as much as possible.
      '';
    };
    modules.boot.luksPrompt = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Indicates that a password prompt needs to show up during boot.
        Reduces the logging removed by a silent boot.
      '';
    };
  };

  config = {

    # Boot options.
    boot = {

      # Configure bootloader to have a maximum of 3 entries,
      # and a timeout of 3 seconds to allow rollbacks.
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
          configurationLimit = lib.mkDefault 3;
          consoleMode = lib.mkDefault "max";
        };
        timeout = lib.mkDefault 3;
      };

      # Set boot options to enable resuming from hibernation.
      initrd.systemd.enable = true;

      # Silent boot implementation.
      # This will interfere with tty if there is no window manager, so it is
      # turned off in that case.
      kernelParams =
        if !config.modules.boot.silentBoot then
          [ ]
        else if config.modules.boot.luksPrompt then
          [
            "quiet"
            "boot.shell_on_fail"
            "udev.log_priority=3"
          ]
        else if config.modules.qtile.enable || config.modules.gnome.enable then
          [
            "quiet"
            "fbcon=vc:2-6"
            "console=tty0"
          ]
        else
          [
            "quiet"
            "udev.log_priority=3"
          ];

    };

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
