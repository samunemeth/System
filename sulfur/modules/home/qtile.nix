# --- Template ---

{ config, pkgs, lib, ... }:
{

  # Copy qtile configuration into place.
  # TODO: Maybe use a relative file path?
  home.file.".config/qtile" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/samu/System/sulfur/qtile";
    recursive = true;
  };

}
