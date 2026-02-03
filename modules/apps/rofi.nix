# --- Rofi ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  wrapped-networkmanager-dmenu = pkgs.symlinkJoin {
    name = "wrapped-networkmanager-dmenu";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.networkmanager_dmenu ];
    postBuild =
      let
        networkmanager-dmenu-config = pkgs.writers.writeText "networkmanager-dmenu-config.ini" ''
          [dmenu]
          dmenu_command = rofi -i
          active_chars = ==
          highlight = True
          highlight_fg =
          highlight_bg =
          highlight_bold = True
          compact = True
          wifi_icons = 󰤯󰤟󰤢󰤥󰤨
          format = {name:<20} {icon:<4} {sec} 
          list_saved = False
          prompt = Networks

          [dmenu_passphrase]
          obscure = False
          obscure_color = ${globals.colors.background.main}

          [editor]
          terminal = alacritty
          gui_if_available = False

          [nmdm]
          rescan_delay = 3
        '';
      in
      ''
        wrapProgram $out/bin/networkmanager_dmenu \
          --add-flags "--config ${networkmanager-dmenu-config}"
      '';
  };

  rofi-plugins = pkgs.stdenvNoCC.mkDerivation {
    name = "rofi-plugins";
    src = ../../src/rofi;
    installPhase = ''
      # Make all the scripts executable.
      chmod +x *
      # Copy contents to output.
      mkdir -p $out
      cp -r * $out/
    '';
  };

  rofi-plugins-string = lib.concatMapAttrsStringSep "," (name: _: "${name}:${rofi-plugins}/${name}") (
    builtins.readDir rofi-plugins
  );

  rofi-config = pkgs.writers.writeText "rofi-config.rasi" ''
    configuration {
      modes: "${rofi-plugins-string}";
      font: "Hack Nerd Font Mono 13";
    }
    @theme "${pkgs.rofi}/share/rofi/themes/Arc${if globals.colors.dark then "-Dark" else ""}.rasi"
  '';

  wrapped-rofi = pkgs.symlinkJoin {
    name = "wrapped-rofi";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.rofi ];
    postBuild = ''
      wrapProgram $out/bin/rofi \
        --add-flags "-config ${rofi-config}"
    '';
  };

in
{

  options.modules = {
    apps.rofi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables the Rofi.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.rofi {

    environment.systemPackages = [

      wrapped-rofi # Simple command running interface with configuration.
      wrapped-networkmanager-dmenu # Network manager plugin for Rofi with configuration.

    ];

    # Require fonts used.
    fonts.packages = [ pkgs.nerd-fonts.hack ];
  };

}
