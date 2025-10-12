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
  users.mutableUsers = false;

  # Default User
  sops.secrets.user-password-hash = { };
  sops.secrets.user-password-hash.neededForUsers = true;
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

  # Root User
  secrets.root-password-hash = { };
  sops.secrets.root-password-hash.neededForUsers = true;
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-password-hash.path;
  };

  # --- Home Manager ---

  home-manager = {
    backupFileExtension = "hmbackup";
    useUserPackages = true;
    useGlobalPkgs = true;
  };

  # --- Sudo ---

  # Enable password prompt for sudo.
  # Make it require the root password.
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraConfig = ''
      Defaults rootpw
    '';
  };

}
