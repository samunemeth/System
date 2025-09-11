{ config, pkgs, lib, globals, inputs, ... }:
{

  # Import all needed modules.
  imports = [

    # Host specific configurations.
    ./hardware-configuration.nix
    ./overrides.nix

    # Common modules containing configuration.
    ../../modules/common/system.nix
    ../../modules/common/boot.nix
    ../../modules/common/gui.nix
    ../../modules/common/local.nix
    ../../modules/common/packages.nix
    ../../modules/common/ssh.nix
    ../../modules/common/audio.nix
    ../../modules/common/files.nix
    ../../modules/common/network.nix
    ../../modules/common/users.nix
    #../../modules/common/theme.nix

    # Program specific configurations.
    ../../modules/programs/neovim.nix
    ../../modules/programs/alacritty.nix
    ../../modules/programs/bash.nix
    ../../modules/programs/firefox.nix
    ../../modules/programs/git.nix
    ../../modules/programs/rofi.nix
    ../../modules/programs/zathura.nix
    ../../modules/programs/qtile.nix
    ../../modules/programs/lf.nix
    ../../modules/programs/latex.nix
    ../../modules/programs/java.nix

  ];

}
