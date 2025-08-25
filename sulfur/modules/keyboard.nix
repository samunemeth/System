# --- Keyboard ---

{ config, pkgs, lib, ... }:
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "hu";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "hu";

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
