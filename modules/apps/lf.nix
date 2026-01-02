# --- Lf ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # WARN: Programs used by the previewer are not linked to the store.
  wrapped-lf = pkgs.symlinkJoin {
    name = "wrapped-lf";
    buildInputs = [ pkgs.makeWrapper ];
    paths = with pkgs; [
      # TODO: Move some to low priority?

      lf # Core.

      highlight # Text file highlighting.
      poppler-utils # Pdf to text conversion.
      exiftool # Getting metadata.

      fd # For recursive funding of files and directories.
      fzf # For fuzzy finding.

      zip # Creating zip files.
      unzip # Unpacking zip files.

    ];
    postBuild =
      let
        lfhome = pkgs.stdenv.mkDerivation {
          name = "lfhome";
          src = ../../apps/lf;
          installPhase = ''
            # Append the location of the previewer script to the configuration.
            echo "set previewer \"$out/lf/previewer.sh\"" >> ./lfrc
            # Make the previewer script executable.
            chmod +x ./previewer.sh
            # Copy contents to output.
            mkdir -p $out/lf
            cp -r * $out/lf/
          '';
        };
      in
      ''
        wrapProgram $out/bin/lf \
          --set LF_CONFIG_HOME ${lfhome}
      '';
  };

in
{

  options.modules = {
    apps.lf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the Lf file manager.
      '';
    };
  };

  config =
    lib.mkAlwaysThenIf config.modules.apps.lf
      {
        modules.export-apps.lf = wrapped-lf;
      }
      {

        environment.systemPackages = [ wrapped-lf ];

        # Add a command to change directories with Lf.
        programs.bash.interactiveShellInit = # bash
          ''
            lfcd () {
              cd "$(command lf -print-last-dir "$@")"
            }
          '';

      };

}
