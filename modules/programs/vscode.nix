# --- VSCode ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    vscode-fhs
    jdk17

  ];


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  home.file.".config/checkstyle_config.xml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/code/checkstyle_config.xml";


  };
}


