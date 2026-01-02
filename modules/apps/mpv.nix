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
    # NOTE: This is actually kind of hardware dependent...
    # > This is ideal for AMD integrated graphics, the OpenGL part should
    # > probably be removed if used on Nvidia.
    postBuild = ''
      wrapProgram $out/bin/mpv \
        --add-flags "\
          --hwdec=yes \
          --gpu-api=opengl \
          --image-display-duration=inf \
          --force-window \
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

  config =
    lib.mkAlwaysThenIf config.modules.apps.mpv
      {
        modules.export-apps.mpv = wrapped-mpv;
      }
      {
        environment.systemPackages = [ wrapped-mpv ];
      };

}
