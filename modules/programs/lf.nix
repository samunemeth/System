# --- Lf ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
let

  # TODO: Programs used by the previewer are not linked to the store.
  wrapped-lf = pkgs.symlinkJoin {
    name = "wrapped-lf";
    buildInputs = [ pkgs.makeWrapper ];
    paths = [ pkgs.lf ];
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
