# --- EduVPN ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options.modules = {
    apps.eduvpn = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Enables EduVPN. Note that onlt the GUI is exposed.
      '';
    };
  };

  config = lib.mkIf config.modules.apps.eduvpn {

    environment.systemPackages = [
      (pkgs.writers.writeBashBin "eduvpn" ''
        ${pkgs.eduvpn-client}/bin/eduvpn-gui
      '')
    ];

  };
}
