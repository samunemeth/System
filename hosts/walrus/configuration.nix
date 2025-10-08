{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}:
{

  # Import all needed modules.
  imports = [

    # Import configuration for WSL.
    inputs.nixos-wsl.nixosModules.default

    # Host specific configurations.
    ./overrides.nix

    # Common modules containing configuration.
    ../../modules/common/system.nix
    ../../modules/common/packages.nix
    ../../modules/common/ssh.nix
    #../../modules/common/files.nix
    ../../modules/common/users.nix

    # Program specific configurations.
    ../../modules/programs/neovim.nix
    ../../modules/programs/bash.nix
    ../../modules/programs/git.nix
    ../../modules/programs/lf.nix

  ];

}
