# --- Boot ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # Required for importing Lanzaboote.
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
    boot.secureboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables secure boot via Lanzaboote.
        IMPORTANT: This option cannot be enabled for the first boot!
        Extra setup is required for rolling in the keys; consult the readme.
      '';
    };
  };

  # Import the Lanzaboote module. Later only enabled if needed.
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  config = {

    # Install tools for managing secure boot.
    environment.systemPackages = lib.lists.optional config.modules.boot.secureboot pkgs.sbctl;

    # Boot options.
    boot = {

      # Configure bootloader to have a maximum of 3 entries,
      # and a timeout of 3 seconds to allow rollbacks.
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {

          # Disable systemd boot if it is replace by Lanzaboote.
          enable = !config.modules.boot.secureboot;

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

      # Enable Lanzaboote on the system if needed.
      lanzaboote = {
        enable = config.modules.boot.secureboot;
        pkiBundle = "/var/lib/sbctl";
      };

    };

  };

}
