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
    ./common/bash.nix
    ./common/boot.nix
    ./common/git.nix
    ./common/locale.nix
    ./common/network.nix
    ./common/packages.nix
    ./common/seafile.nix
    ./common/sops.nix
    ./common/ssh.nix
    ./common/system.nix
    ./common/users.nix
    ./common/yubikey.nix

    # Applications
    ./apps/alacritty.nix
    ./apps/firefox.nix
    ./apps/ipycalc.nix
    ./apps/lf.nix
    ./apps/mpv.nix
    ./apps/neovim.nix
    ./apps/rofi.nix
    ./apps/vscode.nix
    ./apps/zathura.nix

    # Programming Languages
    ./code/haskell.nix
    ./code/java.nix
    ./code/julia.nix
    ./code/latex.nix
    ./code/lua.nix
    ./code/nix.nix
    ./code/python.nix
    ./code/rust.nix

    # User Interfaces
    ./gui/gnome.nix
    ./gui/kmscon.nix
    ./gui/qtile.nix

  ];

  options = { };

  config = { };

}
