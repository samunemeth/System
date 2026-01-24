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

}
