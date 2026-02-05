# --- Rofi ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  rofi-plugins = pkgs.stdenvNoCC.mkDerivation {
    name = "rofi-plugins";
    src = ../../src/rofi;
    installPhase = ''
      # Make all the scripts executable.
      chmod +x *
      # Copy contents to output.
      mkdir -p $out
      cp -r * $out/
    '';
  };

  rofi-plugins-string = lib.concatMapAttrsStringSep "," (name: _: "${name}:${rofi-plugins}/${name}") (
    builtins.readDir rofi-plugins
  );

  rofi-config = pkgs.writers.writeText "rofi-config.rasi" ''
    configuration {
      modes: "${rofi-plugins-string}";
      font: "Hack Nerd Font Mono 13";
    }
    @theme "${pkgs.rofi}/share/rofi/themes/Arc${if globals.colors.dark then "-Dark" else ""}.rasi"
  '';

  wrapped-rofi = pkgs.symlinkJoin {
    name = "wrapped-rofi";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.rofi ];
    postBuild = ''
      wrapProgram $out/bin/rofi \
        --add-flags "-config ${rofi-config}"
    '';
  };

in
{

  options.modules = {
    apps.rofi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables Rofi with plugins.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.rofi {

    environment.systemPackages = [ wrapped-rofi ];

    # Require fonts used.
    fonts.packages = [ pkgs.nerd-fonts.hack ];
  };

}
