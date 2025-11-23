# --- Mpv Media Player ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  wrapped-mpv = pkgs.symlinkJoin {
    name = "wrapped-mpv";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.mpv ];
    postBuild = ''
      wrapProgram $out/bin/mpv \
        --add-flags "\
          --hwdec=yes \
          --gpu-api=opengl \
          --image-display-duration=inf \
          --force-window
        "
    '';
  };

in
{

  options.modules = {
    apps.mpv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Mpv media player.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.mpv {

    environment.systemPackages = [ wrapped-mpv ];

  };

}
