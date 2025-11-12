# --- SSH ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  sops.secrets =
    let
      userOwned = {
        owner = globals.user;
        group = "users";
      };
    in
    {

      # Request "pass" ssh key from sops, and place them in the default location.
      # NOTE: Create a symlink to these later, as despite being owned by the user,
      # > when placing these files, the parent directory gets owned by root.
      # > Because of this, directly placing them in place is unreliable.
      user-ssh-pass-public = userOwned;
      user-ssh-pass-private = userOwned;

      # Request ssh destination shortcuts.
      ssh-destinations = userOwned;

    };

  # Machine ssh settings.
  programs.ssh = {

    # This is required for YubiKey related stuff.
    startAgent = true;

    # Configure known hosts to avoid errors.
    knownHosts = {

      # GitHub public keys.
      # TODO: Check if this is actually needed / good practice.
      "github.com/ed25519" = {
        hostNames = [
          "github.com"
          "www.github.com"
        ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "github.com/sha2" = {
        hostNames = [
          "github.com"
          "www.github.com"
        ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
      };
      "github.com/rsa" = {
        hostNames = [
          "github.com"
          "www.github.com"
        ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      };
    };

  };

  # --- Home Manager Part ---
  home-manager.users.${globals.user} =
    let
      user-ssh-pass-public-path = config.sops.secrets.user-ssh-pass-public.path;
      user-ssh-pass-private-path = config.sops.secrets.user-ssh-pass-private.path;
    in
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home.file = {

        # Link the "pass" ssh keys into place.
        "/home/${globals.user}/.ssh/id_pass.pub".source =
          config.lib.file.mkOutOfStoreSymlink user-ssh-pass-public-path;
        "/home/${globals.user}/.ssh/id_pass".source =
          config.lib.file.mkOutOfStoreSymlink user-ssh-pass-private-path;

      };

      # User ssh settings.
      programs.ssh = {

        enable = true;

        # Pass keys to ssh agent. This is needed for YubiKey.
        extraConfig = ''
          AddKeysToAgent yes
        '';

        # Define what keys to use
        matchBlocks = {

          # Identity for all connections.
          "*" = {
            identityFile = [
              "~/.ssh/id_yubi"
              "~/.ssh/id_pass"
            ];
          };

        };

      };

    };

}
