# --- LaTeX ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # Create a derivation from the outlines that is included in the packages.
  latex-outlines = pkgs.stdenvNoCC.mkDerivation {
    name = "latex-outlines";
    src = ../../src/latex;
    outputs = [ "tex" "out" ];
    installPhase = ''
      mkdir -p $out
      mkdir -p $tex/tex/latex
      cp -r * $tex/tex/latex/
    '';
    passthru.tlType = "run";
  };

  custom-texlive = pkgs.texlive.combine {
    inherit

      # Root packages.
      (pkgs.texlive)
      scheme-basic

      # Technical packages.
      synctex

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
      wasysym
      wasy-type1

      # Packages for markdown.
      booktabs
      mdwtools

      # Language packages.
      babel
      babel-hungarian

      ;

    # Include custom LaTeX outlines.
    custom = { pkgs = [ latex-outlines ]; };

  };

in
{

  options.modules = {
    code.latex = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables support for LaTeX.
        Includes formatter, Neovim plugin, markdown compilation,
        LaTeX packages, and custom outlines.
        Places outlines at expected location.
      '';
    };
  };

  config = lib.mkIf config.modules.code.latex {

    environment.systemPackages = with pkgs; [

      # LaTeX base and packages.
      custom-texlive

      rubber # Helper for LaTeX building.
      pandoc # For markdown to pdf and some other LaTeX based conversions.
      tex-fmt # LaTeX formatter.

    ];

  };
}
