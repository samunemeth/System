# --- LaTeX ---

{ config, pkgs, lib, globals, ... }:
let
  tex = with pkgs; (texlive.combine { inherit

      # Root packages.
      (texlive)
      scheme-basic

      # Math related packages.
      amsmath
      amsfonts
      pgfplots
      flagderiv
      
      # Other packages.
      dirtytalk
      adjustbox
      pgf
      ragged2e
      hyperref
      graphics
      listings

      # Language packages.
      babel
      babel-hungarian

  ;});
in
{

  environment.systemPackages = with pkgs; [

    # The package set defined above.
    tex

    # An optimised LaTeX builder.
    rubber

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


