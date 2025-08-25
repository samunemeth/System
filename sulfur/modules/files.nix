# --- Files ---

{ config, pkgs, lib, ... }:
{

  # Seafile daemon setup.
  environment.systemPackages = with pkgs; [
    seafile-shared
  ];
  systemd.services.seafile-daemon = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.seafile-shared ];
    script = ''
      seaf-cli start
    '';
    serviceConfig = {
      Type = "forking";
      User = "samu";
    };
  };

}
