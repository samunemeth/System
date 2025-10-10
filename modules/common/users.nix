# --- Users ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # --- Users ---

  # Setup for getting the user's password hash.
  sops.secrets.user-password-hash.neededForUsers = true;
  users.mutableUsers = false;

  users.users.${globals.user} = {
    isNormalUser = true;
    description = globals.name;
    extraGroups = [
      "networkmanager"
      "wheel"
      "plugdev"
      "audio"
      "input"
    ];
    hashedPasswordFile = config.sops.secrets.user-password-hash.path;
  };

  # --- Home Manager ---

  home-manager = {
    backupFileExtension = "hmbackup";
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  # Disable sudo password prompt.
  security.sudo.wheelNeedsPassword = false;

}
