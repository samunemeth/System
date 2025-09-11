# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{

  nixpkgs.hostPlatform = "x86_64-linux";
  wsl.enable = true;

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {



  };
}
