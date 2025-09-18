# --- Packages ---

{ config, pkgs, lib, globals, ... }:
{

  # List of packages.
  environment.systemPackages = with pkgs; [

    vim                  # Simple text editor.
    curl                 # Fetching form the web.
    btop                 # System monitoring and testing.
    fastfetchMinimal     # Displaying system data.
    xclip                # Command line clipboard tool.

  ];

  # Remove unused packages enabled my default.
  environment.defaultPackages = lib.mkForce [];
  services.speechd.enable = false;

  # Disable documentation by default, for space saving. 
  documentation.enable = lib.mkDefault false;

  # List of fonts.
  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];


}


