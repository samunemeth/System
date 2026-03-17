# --- Fingerprint Reader ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    system.fprint = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Allows a fingerprint reader to be used for user authentication.
      '';
    };
  };

  config = lib.mkIf config.modules.system.fprint {

    # Enable fingerprint based authentication.
    services.fprintd.enable = true;

    # Shortcuts for adding and deleting fingerprints.
    programs.bash.interactiveShellInit = # bash
      ''
        flist () { fprintd-list $USER; }
        fenroll () { sudo fprintd-enroll $USER; }
        fdelete () { sudo fprintd-delete $USER; }
      '';

  };
}
