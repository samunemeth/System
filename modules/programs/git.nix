# --- Git ---

{ config, pkgs, lib, globals, ... }:
{

  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {

  programs.git = {

    enable = true;
  
    # Configure git to have my user data.
    userName = globals.name;
    userEmail = globals.email;

    extraConfig = {
      pull.rebase = true;
    };
  
  };

  };
}
