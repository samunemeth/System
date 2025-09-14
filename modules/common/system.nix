# --- System ---

{ config, pkgs, lib, globals, ... }:
{

  # Set host name default.
  networking.hostName = lib.mkDefault "nixos";

  # Enable flakes.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set state versions.
  system.stateVersion = globals.stateVersion;
  home-manager.users.${globals.user}.home.stateVersion = globals.stateVersion;

  # Allow unfree packages.
  nixpkgs = {
    system = globals.system;
    config.allowUnfree = true;
  };

  # Automatically optimise packages.
  nix.settings.auto-optimise-store = true;

  # Automatically collect garbage.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    persistent = true;
  };

}
