# --- Java Tools ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    vscode-fhs
    jdk17

  ];


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {



  };
}


