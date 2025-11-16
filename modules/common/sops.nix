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
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

  };

}
