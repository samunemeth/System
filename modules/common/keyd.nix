# --- Keyd ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # TODO: Add an option for this.

  # Enables Keyd remapping daemon.
  services.keyd.enable = true;

  # Modify keyboard layers for all devices.
  services.keyd.keyboards.default.ids = [ "*" ];
  services.keyd.keyboards.default.settings = {

    # Main layer.
    "main" = {
      "capslock" = "esc"; # Caps lock to escape.
      "leftshift+rightshift" = "capslock"; # Double shift to caps lock,
      "f23+leftshift+leftmeta" = "M-a"; # This is the copilot key.
      "leftalt" = "layer(special)"; # Alt to special layer.
    };

    # Spacial layer.
    "special" = {

      # Movement and control.
      "h" = "left";
      "k" = "up";
      "j" = "down";
      "l" = "right";
      "p" = "enter";
      ";" = "backspace";

      # Pass through.
      "space" = "A-space";

      # Accented characters.
      # TODO: Move to a different layer?
      "e" = "macro(compose e ')";
      "a" = "macro(compose a ')";
      "i" = "macro(compose i ')";
      "u" = "macro(compose u ')";
      "o" = "macro(compose o ')";
      "n" = "macro(compose u \")";
      "m" = "macro(compose o \")";
      "[" = "macro(compose = u)";
      "]" = "macro(compose = o)";

      # Simpler virtual terminal switching.
      "f1" = "A-C-f1";
      "f2" = "A-C-f2";
      "f3" = "A-C-f3";
      "f4" = "A-C-f4";
      "f5" = "A-C-f5";
      "f6" = "A-C-f6";
      "f7" = "A-C-f7";
      "f8" = "A-C-f8";
      "f9" = "A-C-f9";
      "f10" = "A-C-f10";
      "f11" = "A-C-f11";
      "f12" = "A-C-f12";

    };
    "special+shift" = {

      # Capital accented characters.
      "e" = "macro(compose E ')";
      "a" = "macro(compose A ')";
      "i" = "macro(compose I ')";
      "u" = "macro(compose U ')";
      "o" = "macro(compose O ')";
      "n" = "macro(compose U \")";
      "m" = "macro(compose O \")";
      "[" = "macro(compose = U)";
      "]" = "macro(compose = O)";

    };

  };

  # Make palm rejection work with Keyd.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

}
