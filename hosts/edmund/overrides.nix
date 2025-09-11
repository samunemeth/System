# --- Overrides for Joseph ---

{ config, pkgs, lib, globals, ... }:
{

  wsl.enable = true;

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {



  };
}
