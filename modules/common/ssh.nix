# --- SSH ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Add default password protected ssh key to the .ssh folder.
  sops.secrets.user-ssh-pass-public = {
    owner = globals.user;
    group = "users";
    path = "/home/${globals.user}/.ssh/id_pass.pub";
  };
  sops.secrets.user-ssh-pass-private = {
    owner = globals.user;
    group = "users";
    path = "/home/${globals.user}/.ssh/id_pass";
  };

  # Machine ssh settings.
  programs.ssh = {

    # Configure known hosts to avoid errors.
    knownHosts = {

      # GitHub public keys.
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
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      # User ssh settings.
      programs.ssh = {

        enable = true;

        # Pass keys to ssh agent. This is needed for YubiKey.
        extraConfig = ''
          AddKeysToAgent yes
        '';

        # Define what keys to use
        matchBlocks = {

          # Use `yubi` as the primary, `pass` for fallback for GitHub.
          "git" = {
            host = "github.com";
            user = "git";
            identityFile = [
              "~/.ssh/id_yubi"
              "~/.ssh/id_pass"
            ];
          };

        };

      };

    };

}
