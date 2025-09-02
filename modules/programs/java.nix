# --- Java Tools ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    vscode
    jdk17

  ];


  # Put other global configuration here.


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  home.packages = with pkgs; [


    # Put user packages here.


  ];


  programs.vscode = {
    enable = true;
    profiles.${globals.user}.extensions = [
      
    ];
  };


  };
}


