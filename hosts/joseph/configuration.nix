{ config, pkgs, lib, globals, inputs, ... }:
{

  # Import all needed modules.
  imports = [

    # Host specific configurations.
    ./hardware-configuration.nix
    ./overrides.nix

    # Include all modules.
    ../../modules/root.nix

  ];

}
