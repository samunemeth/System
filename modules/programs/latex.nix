# --- LaTeX ---

{ config, pkgs, lib, globals, ... }:
{

  environment.systemPackages = with pkgs; [

    # I'm still unsure what size I actually need.  

    # texliveFull
    # texliveMedium
    texliveSmall
    # texliveBasic
    # texliveMinimal

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


