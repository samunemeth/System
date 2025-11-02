# --- Lf ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  wrapped-lf = pkgs.symlinkJoin {
    name = "wrapped-lf";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.lf ];
    postBuild =
      let

        # A script for previewing files.
        previewerScript = pkgs.writers.writeBash "lfprev" (builtins.readFile ../../apps/lf/previewer.sh);

        # Program configuration, with the location of the previewer script.
        configFile = pkgs.writers.writeText "lfrc" (
          (builtins.readFile ../../apps/lf/lfrc)
          + ''
            set previewer "${previewerScript}"
          ''
        );

        # Configuration file for icons. This needs to be inside a directory structure.
        configHome = pkgs.stdenv.mkDerivation {
          name = "lfhome";
          unpackPhase = "true";
          installPhase = ''
            mkdir -p $out/lf
            cat > $out/lf/icons <<EOF
            ${builtins.readFile ../../apps/lf/icons}
            EOF
            chmod 644 $out/lf/icons
          '';
        };
      in
      ''
        wrapProgram $out/bin/lf \
          --append-flags "-config ${configFile}" \
          --set LF_CONFIG_HOME ${configHome}
      '';

  };

in
{

  # Packages for previewing files, and some other tasks.
  # TODO: Move some to low priority?
  environment.systemPackages = with pkgs; [

    wrapped-lf # Terminal file manager with configuration.

    highlight # Text file highlighting.
    poppler-utils # Pdf to text conversion.
    exiftool # Getting metadata.
    zip # Creating zip files.
    unzip # Unpacking zip files.
    ripgrep # Recursive command line search command.

  ];

  # Add a command to change directories with Lf.
  programs.bash.interactiveShellInit = # bash
    ''
      lfcd () {
        cd "$(command lf -print-last-dir "$@")"
      }
    '';

}
