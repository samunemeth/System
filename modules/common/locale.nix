# --- Locale ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    locale.keyboardLayouts = lib.mkOption {
      type = lib.types.listOf lib.types.nonEmptyStr;
      default = [
        "us"
        "hu"
      ];
      example = [
        "hu"
        "us dvp"
      ];
      description = ''
        A list of keyboard layouts to make available in the switcher.
        The keyboard layout may be followed by a space and a variant.
        The first keyboard layout will be used as default.
      '';
    };
    locale.timeZone = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "Etc/Universal";
      example = "Europe/Amsterdam";
      description = ''
        Set the time zone of the machine.
      '';
    };
  };

  config =
    let

      # Do some transformations on the keyboard layouts list.
      keyboard = builtins.split " " (builtins.head config.modules.locale.keyboardLayouts);
      hasVariant = if builtins.length keyboard >= 3 then true else false;
      keyboardLayout = builtins.head keyboard;
      keyboardVariant = if hasVariant then builtins.elemAt keyboard 2 else "";

    in
    {

      # Set time zone to CET.
      time.timeZone = config.modules.locale.timeZone;

      # Keep the hardware clock of the machine on local time. This fixes the
      # issue of windows displaying UTC time as local time.
      # After this setting is enabled, the hardware clock may not be updated
      # instantly. Run the following to check the status of the clocks:
      # $ timedatectl
      # To force a write to the local RTC clock, run the following:
      # $ sudo hwclock --systohc --localtime
      time.hardwareClockInLocalTime = true;

      # Set default US locales.
      i18n.defaultLocale = "en_US.UTF-8";

      # Configure keyboard layout.
      services.xserver.xkb = {
        layout = keyboardLayout;
        variant = keyboardVariant;
        options = "compose:menu";
      };
      console.useXkbConfig = true;

      # Use natural scrolling, as I am used to it.
      services.libinput.touchpad.naturalScrolling = true;

    };
}
