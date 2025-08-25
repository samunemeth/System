# --- Theme ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {
 
  # Required packages.
  home.packages = with pkgs; [

    adwaita-icon-theme
    adwaita-qt

  ];


  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    theme = lib.mkForce {
      name = "Nightfox-Dark";
      package = pkgs.nightfox-gtk-theme;
    };
    iconTheme = {
      name = "Adwaita-Dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  };
}
