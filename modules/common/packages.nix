# --- Packages ---

{ config, pkgs, lib, globals, ... }:
{

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List of packages.
  environment.systemPackages = with pkgs; [

    vim                  # Simple text editor.
    curl                 # Fetching form the web.
    btop                 # System monitoring and testing.
    # speedtest-cli        # Internet speed testing.
    fastfetchMinimal     # Displaying system data.
    gcc                  # C code compilation.
    nodejs_24            # Node.js distribution.
    zathura              # Minimalistic pdf viewer.
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
    pulseaudio-ctl       # Command line volume control.

  ];

  # Remove unused packages enabled my default.
  services.speechd.enable = false;

  # List of fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

}


