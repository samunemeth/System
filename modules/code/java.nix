# --- Java ---

{ config, pkgs, lib, globals, ... }:
{
  config = lib.mkIf config.modules.packages.programming {

    environment.systemPackages = with pkgs; [

      jdk17

    ];


    # --- Home Manager Part ---
    home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

    home.file.".config/checkstyle_config.xml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/code/checkstyle_config.xml";


    };

  };
}


