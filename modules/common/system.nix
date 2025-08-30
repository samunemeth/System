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

  # Automatically optimise packages.
  nix.settings.auto-optimise-store = true;

}
