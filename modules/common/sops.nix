# --- Sops ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  environment.systemPackages = with pkgs; [

    sops # For secret management.
    ssh-to-age # For editing the secrets with the host key.

  ];

  # Configuration for sops.
  sops = {

    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age = {

      # Use machine host SSH key derived age keys.
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = true;
      keyFile = "/var/lib/sops-nix/keys.txt";
    };

  };

  # Edit NixOS secrets, with the machines host ssh key.
  programs.bash.interactiveShellInit = # bash
    ''
      nes () {
        cd ~/System
        SOPS_AGE_KEY=$( \
          sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key \
        ) \
        sops $1 secrets.yaml
        cd -
      }
    '';

}
