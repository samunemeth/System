# --- Template ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  environment.systemPackages = with pkgs; [

    # Put global packages here.

  ];

  # Put other global configuration here.

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home.packages = with pkgs; [

        # Put user packages here.

      ];

      # Put other user configuration here.

    };
}
