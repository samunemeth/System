# --- Sulfur ---

{ config, pkgs, lib, globals, ... }:
{

  # Import all needed modules.
  imports = [

    # Custom modules containing configuration.
    ./modules/boot.nix
    ./modules/gui.nix
    ./modules/local.nix
    ./modules/packages.nix
    ./modules/ssh.nix
    ./modules/audio.nix
    ./modules/files.nix
    ./modules/network.nix
    ./modules/users.nix
    #./modules/theme.nix

    # Program specific configurations.
    ./modules/neovim.nix
    ./modules/alacritty.nix
    ./modules/bash.nix
    ./modules/firefox.nix
    ./modules/git.nix
    ./modules/rofi.nix
    ./modules/zathura.nix
    ./modules/qtile.nix
    ./modules/lf.nix

  ];

  # Enable flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Override Settings ---
  # Override keyboard layout from local.nix (change from "hu" to "us")
  # Uncomment the lines below to change keyboard layout to US:
  # services.xserver.xkb.layout = "us";
  # console.keyMap = "us";

  # Set state versions.
  system.stateVersion = globals.stateVersion;
  home-manager.users.${globals.user}.home.stateVersion = globals.stateVersion;

}
