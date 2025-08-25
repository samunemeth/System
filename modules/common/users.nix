# --- Users ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Users ---


  users.users.${globals.user} = {
    isNormalUser = true;
    description = globals.name;
    extraGroups = [ "networkmanager" "wheel" "plugdev" "audio" ];
  };


  # --- Home Manager ---


  home-manager = {
    backupFileExtension = "hmbackup";
    useUserPackages = true;
  };


  # Disable sudo password prompt.
  security.sudo.wheelNeedsPassword = false;

}


