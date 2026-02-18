# --- Alacritty ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  alacritty-config = pkgs.writers.writeTOML "alacritty-config.toml" {

    # Configure a minimalistic GUI.
    window = {
      padding = {
        x = 5;
        y = 5;
      };
      decorations = "none";
      dynamic_title = true;
      dynamic_padding = true;
    };

    # Set background to global setting.
    colors.primary.background = globals.colors.background.main;

    # Scroll back history size.
    scrolling.history = 1000;

    # Set fonts for each different style.
    font = {
      normal = {
        family = "Hack Nerd Font Mono";
        style = "Regular";
      };
      bold = {
        family = "Hack Nerd Font Mono";
        style = "Bold";
      };
      italic = {
        family = "Hack Nerd Font Mono";
        style = "Italic";
      };
      bold_italic = {
        family = "Hack Nerd Font Mono";
        style = "Bold Italic";
      };
      size = if config.modules.system.isDesktop then 12 else 8;
    };

  };

  wrapped-alacritty = pkgs.symlinkJoin {
    name = "wrapped-alacritty";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.alacritty ];
    postBuild = ''
      wrapProgram $out/bin/alacritty \
        --add-flags "\
          --config-file=${alacritty-config} \
        "
    '';
  };

in
{

  options.modules = {
    apps.alacritty = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Alacritty Terminal emulator.
      '';
    };
  };

  config =
    lib.mkAlwaysThenIf config.modules.apps.alacritty
      {
        modules.export-apps.alacritty = wrapped-alacritty;
      }
      {

        environment.systemPackages = [ wrapped-alacritty ];

        # Update environment settings.
        environment.sessionVariables = {
          TERM = "alacritty";
          TERMINAL = "alacritty";
        };

        # Remove xterm, as Alacritty becomes default.
        services.xserver = {
          desktopManager.xterm.enable = false;
          excludePackages = [ pkgs.xterm ];
        };

        # Require fonts used.
        fonts.packages = [ pkgs.nerd-fonts.hack ];

      };

}
