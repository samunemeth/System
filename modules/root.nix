# --- Root for Modules ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs,
  ...
}:
{

  # Import all modules.
  imports = [

    # Common modules containing configuration.
    ./common/system.nix
    ./common/boot.nix
    ./common/local.nix
    ./common/packages.nix
    ./common/ssh.nix
    ./common/audio.nix
    ./common/files.nix
    ./common/network.nix
    ./common/users.nix
    ./common/sops.nix
    ./common/yubikey.nix

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
    ./programs/java.nix
    ./programs/gnome.nix

  ];

  options = {
    modules.isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Weather the machine is a desktop machine. If true, disables touch
        input gestures.
      '';
    };
  };

  config = { };

}
