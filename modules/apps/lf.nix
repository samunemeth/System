# --- Lf ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  lf-home = pkgs.stdenvNoCC.mkDerivation {
    name = "lf-home";
    src = ../../src/lf;
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

  wrapped-lf = pkgs.symlinkJoin {
    name = "wrapped-lf";
    buildInputs = [ pkgs.makeWrapper ];
    paths = with pkgs; [
      # TODO: Move some to low priority?

      lf # Core.

      jq # For URL encoding.
      xclip # For copying to the clipboard.
      highlight # Text file highlighting.
      poppler-utils # Pdf to text conversion.
      exiftool # Getting metadata.

      fd # For recursive funding of files and directories.
      fzf # For fuzzy finding.

      zip # Creating zip files.
      unzip # Unpacking zip files.

    ];
    postBuild = ''
      wrapProgram $out/bin/lf \
        --set LF_CONFIG_HOME ${lf-home}
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
