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

  imports = [

    # General Modules
    ./common/system.nix
    ./common/boot.nix
    ./common/locale.nix
    ./common/packages.nix
    ./common/ssh.nix
    ./common/audio.nix
    ./common/network.nix
    ./common/users.nix
    ./common/sops.nix
    ./common/yubikey.nix
    ./common/bash.nix

    # Applications
    ./apps/neovim.nix
    ./apps/alacritty.nix
    ./apps/firefox.nix
    ./apps/git.nix
    ./apps/rofi.nix
    ./apps/zathura.nix
    ./apps/lf.nix
    ./apps/vscode.nix
    ./apps/seafile.nix
    ./apps/mpv.nix

    # Programming Languages
    ./code/latex.nix
    ./code/java.nix
    ./code/rust.nix
    ./code/python.nix

    # User Interfaces
    ./gui/gnome.nix
    ./gui/kmscon.nix
    ./gui/qtile.nix

  ];

  options = { };

  config = { };

}
