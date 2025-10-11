# --- Local ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  config =
    let

      keyboard = builtins.split " " (builtins.head config.modules.local.keyboardLayouts);
      hasVariant = if builtins.length keyboard >= 3 then true else false;
      keyboardLayout = builtins.head keyboard;
      keyboardVariant = if hasVariant then builtins.elemAt keyboard 2 else "";

    in
    {

      # Set time zone to CET.
      time.timeZone = lib.mkDefault "Europe/Amsterdam";

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
      services.xserver.xkb = {
        layout = keyboardLayout;
        variant = keyboardVariant;
        options = "compose:menu";
      };
      console.keyMap = keyboardLayout;

      # Use natural scrolling, as I am used to it.
      services.libinput.touchpad.naturalScrolling = true;

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
              "f23+leftshift+leftmeta" = "M-a";
            };
            "alt" = {
              "h" = "left";
              "k" = "up";
              "j" = "down";
              "l" = "right";
              "p" = "enter";
              ";" = "backspace";
            }
            // {
              "e" = "macro(compose e ')";
              "a" = "macro(compose a ')";
              "i" = "macro(compose i ')";
              "u" = "macro(compose u ')";
              "o" = "macro(compose o ')";
              "n" = "macro(compose u \")";
              "m" = "macro(compose o \")";
              "[" = "macro(compose = u)";
              "]" = "macro(compose = o)";
            };
            "alt+shift" = {
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

    };
}
