# --- Root for Modules ---

{ config, pkgs, lib, globals, inputs, ... }:
{

  # Import all modules.
  imports = [

    # Common modules containing configuration.
    ./common/system.nix
    ./common/boot.nix
    ./common/gui.nix
    ./common/local.nix
    ./common/packages.nix
    ./common/ssh.nix
    ./common/audio.nix
    ./common/files.nix
    ./common/network.nix
    ./common/users.nix

    # Program specific configurations.
    ./programs/neovim.nix
    ./programs/alacritty.nix
    ./programs/bash.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/rofi.nix
    ./programs/zathura.nix
    ./programs/qtile.nix
    ./programs/lf.nix
    ./programs/latex.nix
    ./programs/vscode.nix

    # Configurations for specializations.
    ./specialisations/lite.nix

  ];

  options = {
    modules.packages.lowPriority = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        By default, there are some packages included that are not used that
        often, but are sometimes useful. Setting this to false will slightly
        reduce the size of the installation, but may cause inconveniences.
      '';
    };
    modules.packages.programming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Adds VSCode and Java.
      '';
    };
  };

  config = {};

}


