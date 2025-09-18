# --- Rofi ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    rofi                 # Stylish Dmenu alternative.
    rofi-calc            # Calculator plugin for Rofi.
    networkmanager_dmenu # Network manager plugin for Rofi.
  
  ];

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

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
    rescan_delay = 5

  '';

  };
}
