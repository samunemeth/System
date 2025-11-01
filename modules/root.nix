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
    ./common/network.nix
    ./common/users.nix
    ./common/sops.nix
    ./common/yubikey.nix
    ./common/bash.nix

    # Program specific configurations.
    ./programs/neovim.nix
    ./programs/alacritty.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/rofi.nix
    ./programs/zathura.nix
    ./programs/lf.nix
    ./programs/latex.nix
    ./programs/vscode.nix
    ./programs/java.nix
    ./programs/seafile.nix
    ./programs/rust.nix
    ./programs/python.nix

    # User interfaces.
    ./gui/gnome.nix
    ./gui/kmscon.nix
    ./gui/qtile.nix

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
