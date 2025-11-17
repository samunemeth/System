# --- LaTeX ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    code.latex = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for LaTeX.
      '';
    };
  };

  config = lib.mkIf config.modules.code.latex {

    environment.systemPackages = with pkgs; [

      # LaTeX base and packages.
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

          # Packages for markdown.
          booktabs
          mdwtools

          # Language packages.
          babel
          babel-hungarian

          ;
      })

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
