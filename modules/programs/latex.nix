# --- LaTeX ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    # texliveFull          # LaTeX package. (This takes up LOTS of space)
    texliveMedium        # LaTeX package. (This takes up a bit less space)
    rubber               # An optimised LaTeX builder.

  ];


  # --- Home Manager Part ---
  home-manager.users.${globals.user} = { config, pkgs, lib, ... }: {


  # LaTeX outline files.
  home.file."texmf/tex/latex" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/latex";
    recursive = true;
  };


  };
}


