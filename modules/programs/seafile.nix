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
      default = false;
      example = true;
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

      # Start and set up the Seafile daemon automatically.
      systemd.services.seafile-daemon = {

        # Check for a network connection by trying to resolve google.com
        preStart = "${pkgs.host}/bin/host google.com";

        # Run after a network connection is available.
        wantedBy = [ "default.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        # `seaf-cli` and `host` commands needed in path.
        path = [ pkgs.seafile-shared pkgs.host ];

        # Script for setting up Seafile.
        script = ''

          # Stop for good measure. It may not work however...
          seaf-cli stop || true

          # Create and initialize if not yet done. If already initialised,
          # nothing happens. Run the daemon after that.
          mkdir -p /home/${globals.user}/.seafile-client
          seaf-cli init -d /home/${globals.user}/.seafile-client
          seaf-cli start

          # Black magic with repos.
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
              seaf-cli sync -l "$repoid" -s "$remoteurl" -d "$repoloc" -u "$remoteuser" -p "$remotepass" || true
            fi
          done


        '';
        serviceConfig = {
          Type = "forking";
          User = globals.user;

          # Restart if there is no network connection yet.
          Restart = "on-failure";
          RestartSec = "10sec";
        };
      };

    }
  );

}
