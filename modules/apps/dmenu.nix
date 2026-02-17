# --- Dmenu ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # NOTE: The patch works with dmenu 5.4 as well, but future versions are not
  # > guaranteed to work.
  dmenu-package = pkgs.dmenu.override {
    patches = [
      (pkgs.fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.2.diff";
        hash = "sha256-QdY2T/hvFuQb4NAK7yfBgBrz7Ii7O7QmUv0BvVOdf00=";
      })
    ];
  };

  # Configure dmenu such that it covers the qtile status bar, and uses the same
  # colors and font to blend in.
  wrapped-dmenu = pkgs.symlinkJoin {
    name = "wrapped-dmenu";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ dmenu-package ];
    postBuild = ''
      wrapProgram $out/bin/dmenu \
        --add-flags " \
          -b -i \
          -fn \"Hack Nerd Font Mono:size=11\" \
          -nb \"${globals.colors.background.contrast}\" \
          -nf \"${globals.colors.foreground.main}\" \
          -sb \"${globals.colors.background.contrast}\" \
          -sf \"${globals.colors.foreground.select}\" \
          -h 26 \
        "
    '';
  };

  dmenu-scripts = pkgs.stdenvNoCC.mkDerivation {
    name = "dmenu-plugins";
    src = ../../src/dmenu;
    nativeBuildInputs = [ pkgs.rename ];
    installPhase = ''
      # Rename all the scripts.
      rename 's/^/dmenu-/; s/\.sh$//' *
      # Make all of the executable.
      chmod +x *
      # Copy contents to output.
      mkdir -p $out/bin
      cp -r * $out/bin/
    '';
  };

in
{

  options.modules = {
    apps.dmenu = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables the Dmenu fuzzy finder.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.dmenu {

    environment.systemPackages = [
      wrapped-dmenu
      dmenu-scripts
    ];

    # Require fonts used.
    fonts.packages = [ pkgs.nerd-fonts.hack ];
  };

}
