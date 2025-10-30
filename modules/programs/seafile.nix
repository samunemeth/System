# --- Files ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  options = {
    modules.seafile.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = ''
        Enables the seafile daemon for file scncing.
      '';
    };
  };

  config = lib.mkIf config.modules.seafile.enable {

    environment.systemPackages = with pkgs; [
      seafile-shared
    ];

    # Start the Seafile daemon automatically.
    systemd.services.seafile-daemon = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.seafile-shared ];
      script = ''
        seaf-cli start
      '';
      serviceConfig = {
        Type = "forking";
        User = globals.user;
      };
    };

  };

}
