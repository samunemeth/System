# --- Local ---

{ config, pkgs, lib, globals, ... }:
{

  # Set time zone to CET.
  time.timeZone = "Europe/Amsterdam";

  # Select the en_US locale, as this is the default,
  # and should be supported by all programs.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keyboard layout.
  services.xserver.xkb = lib.mkDefault {
    layout = "us";
    variant = "";
  };
  console.keyMap = lib.mkDefault "us";

  # Configure keyd to remap caps lock to escape.
  # Pressing both shifts acts as the new caps lock key.
  # Holding alt with your thumb acts as a nav layer.
  # Keyd works independent of the keyboard layout and GUI,
  # as in intercepts the keyboard input directly.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        "main" = {
          "capslock" = "esc";
          "leftshift+rightshift" = "capslock";

          # Copilot key remapping.
          "f23+leftshift+leftmeta" = "capslock";
        };
        "alt" = {
          "h" = "left";
          "k" = "up";
          "j" = "down";
          "l" = "right";
          "p" = "enter";
          ";" = "backspace";
        };
      };
    };
  };

  # Makes palm rejection work with keyd.
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

}
