# --- Overrides for Sulfur ---

{ config, pkgs, lib, globals, ... }:
{


  # Put other global configuration here.


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  # Put other user configuration here.


  };
}
