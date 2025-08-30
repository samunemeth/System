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
    fastfetchMinimal     # Displaying system data.
    gcc                  # C code compilation.
    nodejs_24            # Node.js distribution.
    xclip                # Command line clipboard tool.
    ripgrep              # Recursive command line search command.
    fd                   # A user friendly file search engine.

    # vlc                  # For media playback
    # flameshot            # For interactive screenshots
    # speedtest-cli        # Internet speed testing.

  ];

  # Remove unused packages enabled my default.
  services.speechd.enable = false;

  # List of fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  # Automatically optimise packages.
  nix.settings.auto-optimise-store = true;

}


