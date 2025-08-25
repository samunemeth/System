# --- Packages ---

{ config, pkgs, lib, globals, ... }:
{

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List of packages.
  environment.systemPackages = with pkgs; [

    vim                  # Default editor.
    # wget                 # Fetching form the web.
    curl                 # Fetching form the web.
    btop                 # System monitoring and testing.
    # speedtest-cli        # Internet speed testing.
    fastfetchMinimal     # Displaying system data.
    gcc                  # C code compilation.
    nodejs_24            # Node.js distribution.
    git                  # Version control.
    zathura              # Minimalistic pdf viewer.
    # networkmanager       # Network connection management. Do I need this?
    pinentry             # Password input.
    hsetroot             # For background setting.
    # vlc                  # For media playback
    flameshot            # For interactive screenshots
    # nsxiv                # Minimalistic image viewer.
    # dunst                # Notification server.
    # lm_sensors           # Read system sensors.
    brightnessctl        # Built in monitor brightness control.
    # acpilight            # Alternative brightness controller.
    xclip                # Command line clipboard tool.
    ripgrep              # Recursive command line search command.
    fd                   # A user friendly file search engine.
    # texliveFull          # LaTeX package. (This takes up LOTS of space)
    texliveMedium        # LaTeX package. (This takes up a bit less space)
    rubber               # An optimised LaTeX builder.
    rofi                 # Stylish Dmenu alternative.
    rofi-calc            # Calculator plugin for Rofi.
    networkmanager_dmenu # Network manager plugin for Rofi.
    pulseaudio-ctl       # Command line volume control.
    tree-sitter          # Neovim parser generator.
    warpd                # Keyboard mouse control and movement emulation.

  ];

}


