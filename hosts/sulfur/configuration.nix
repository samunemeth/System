# --- Sulfur ---

{ config, pkgs, lib, globals, ... }:
{

  # Import all needed modules.
  imports = [

    # Custom modules containing configuration.
    ../../modules/common/boot.nix
    ../../modules/common/gui.nix
    ../../modules/common/local.nix
    ../../modules/common/packages.nix
    ../../modules/common/ssh.nix
    ../../modules/common/audio.nix
    ../../modules/common/files.nix
    ../../modules/common/network.nix
    ../../modules/common/users.nix
    #../../modules/common/theme.nix

    # Program specific configurations.
    ../../modules/programs/neovim.nix
    ../../modules/programs/alacritty.nix
    ../../modules/programs/bash.nix
    ../../modules/programs/firefox.nix
    ../../modules/programs/git.nix
    ../../modules/programs/rofi.nix
    ../../modules/programs/zathura.nix
    ../../modules/programs/qtile.nix
    ../../modules/programs/lf.nix

  ];

  # Enable flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set state versions.
  system.stateVersion = globals.stateVersion;
  home-manager.users.${globals.user}.home.stateVersion = globals.stateVersion;

}
