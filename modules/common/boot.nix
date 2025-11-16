# --- Boot ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    boot.silentBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Silences the boot sequence as much as possible.
      '';
    };
    boot.luksPrompt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Indicates that a password prompt needs to show up during boot.
        Reduces the logging removed by a silent boot.
      '';
    };
    boot.autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables automatic login.
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

      # Silent boot implementation. This will interfere with tty if there is
      # no window manager, so it is turned off in that case.
      kernelParams =
        if !config.modules.boot.silentBoot then
          [ ]
        else if config.modules.boot.luksPrompt then
          [
            "quiet"
            "boot.shell_on_fail"
            "udev.log_priority=3"
          ]
        else if config.modules.gui.qtile || config.modules.gui.gnome then
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

  };

}
