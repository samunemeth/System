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

  wrapped-rofi = pkgs.symlinkJoin {
    name = "wrapped-rofi";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.rofi ];
    postBuild =
      let
        rofi-config = pkgs.writers.writeText "rofi-config.rasi" ''
          configuration {
            font: "Hack Nerd Font Mono 13";
          }
          @theme "${pkgs.rofi}/share/rofi/themes/Arc${if globals.colors.dark then "-Dark" else ""}.rasi"
        '';
      in
      ''
        wrapProgram $out/bin/rofi \
          --add-flags "-config ${rofi-config}"
      '';
  };

in
{

  # BUG: The rofi-calc plugin is missing.
  environment.systemPackages = with pkgs; [

    wrapped-rofi # Simple command running interface with configuration.
    wrapped-networkmanager-dmenu # Network manager plugin for Rofi with configuration.

  ];

  # Require fonts used.
  fonts.packages = [ pkgs.nerd-fonts.hack ];

}
