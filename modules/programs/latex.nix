# --- LaTeX ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let
  tex =
    with pkgs;
    (texlive.combine {
      inherit

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

        ;
    });
in
{

  config = lib.mkIf config.modules.packages.latex {

    environment.systemPackages = with pkgs; [

      tex # The package set defined above.
      rubber # Helper for latex building.
      pandoc # For markdown to pdf and some other LaTeX based conversions.

    ];

    # --- Home Manager Part ---
    home-manager.users.${globals.user} =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {

        # LaTeX outline files.
        home.file."texmf/tex/latex" = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/System/apps/latex";
          recursive = true;
        };

      };
  };
}
