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
    modules.seafile.repos = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {};
      description = '''';
    };
  };

  config = lib.mkIf config.modules.seafile.enable (
    let

      seafile-repos = config.modules.seafile.repos;
      seafile-repoids =
        "\"" + (builtins.concatStringsSep "\" \"" (builtins.attrNames seafile-repos)) + "\"";
      seafile-repolocs =
        "\"" + (builtins.concatStringsSep "\" \"" (builtins.attrValues seafile-repos)) + "\"";

      userOwnedSecret = {
        owner = globals.user;
        group = "users";
      };

    in
    {

      environment.systemPackages = with pkgs; [
        seafile-shared
      ];

      # Request secrets for Seafile.
      sops.secrets.seafile-url = userOwnedSecret;
      sops.secrets.seafile-user = userOwnedSecret;
      sops.secrets.seafile-pass = userOwnedSecret;

      # Start the Seafile daemon automatically.
      systemd.services.seafile-daemon = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.seafile-shared ];
        script = ''

          mkdir -p /home/${globals.user}/.seafile-client
          seaf-cli init -d /home/${globals.user}/.seafile-client
          seaf-cli start

          repoids=(${seafile-repoids})
          repolocs=(${seafile-repolocs})

          remoteurl=$(< ${config.sops.secrets.seafile-url.path})
          remoteuser=$(< ${config.sops.secrets.seafile-user.path})
          remotepass=$(< ${config.sops.secrets.seafile-pass.path})

          for i in "''${!repoids[@]}"; do
            repoid="''${repoids[i]}"
            repoloc="/home/${globals.user}/''${repolocs[i]}"
            printf "Looking at %s with location %s\n" $repoid $repoloc
            if seaf-cli list | grep -q "$repoid"; then
              echo "$repoid already synced."
            else
              echo "Adding $repoid to sync."
              mkdir -p "$repoloc"
              seaf-cli sync -l "$repoid" -s "$remoteurl" -d "$repoloc" -u "$remoteuser" -p "$remotepass"
            fi
          done


        '';
        serviceConfig = {
          Type = "forking";
          User = globals.user;
        };
      };

    }
  );

}
