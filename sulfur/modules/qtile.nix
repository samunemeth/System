# --- Template ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  # Link Qtile configuration into place.
  home.file.".config/qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/sulfur/qtile";
    recursive = true;
  };

  };
}
