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

      jq # For URL encoding. # TODO: We sure we need this?
      xclip # For copying to the clipboard.
      highlight # Text file highlighting. # TODO: Can I just Neovim for this?
      poppler-utils # Pdf to text conversion. # TODO: Make minimal?
      exiftool # Getting metadata.

      fd # For recursive funding of files and directories.
      fzf # For fuzzy finding.

      zip # Creating zip files.
      unzip # Unpacking zip files.

      img2pdf # For converting images to pdf.

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

        environment.systemPackages = with pkgs; [
          wrapped-lf

          openssl # For time stamping.
        ];

        # Add a command to change directories with Lf.
        programs.bash.interactiveShellInit = # bash
          ''
            lfcd () {
              cd "$(command lf -print-last-dir "$@")"
            }
          '';

      };

}
