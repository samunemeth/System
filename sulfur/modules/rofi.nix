# --- Rofi ---

{ config, pkgs, lib, globals, ... }:
{

  home-manager.users.${globals.user} = {

  programs.rofi = {

    enable = true;

    package = pkgs.rofi;
    font = "Hack Nerd Font Mono 13";
    theme = "${pkgs.rofi}/share/rofi/themes/Arc-Dark.rasi";

    plugins = with pkgs; [
      rofi-calc
      rofi-power-menu
    ];

  };

  # Configuration for network manager dmenu.
  home.file.".config/networkmanager-dmenu/config.ini".text = ''

    [dmenu]
    dmenu_command = rofi -i
    active_chars = ==
    highlight = True
    highlight_fg =
    highlight_bg =
    highlight_bold = True
    compact = True
    pinentry = pinentry
    wifi_icons = 󰤯󰤟󰤢󰤥󰤨
    format = {name:<20} {icon:<4} {sec} 
    list_saved = False
    prompt = Networks
    
    [dmenu_passphrase]
    obscure = False
    obscure_color = #222222
    
    [pinentry]
    description = Get network password
    prompt = Password:
    
    [editor]
    terminal = alacritty
    gui_if_available = False
    
    [nmdm]
    rescan_delay = 5

  '';

  };
}
