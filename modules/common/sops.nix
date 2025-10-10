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

  ];

  # Generate host ssh keys.
  services.openssh = {
    enable = true;
    ports = [ 2142 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = lib.mkForce [ globals.user ];
    };
  };

  # Configuration for sops.
  sops = {

    defaultSopsFile = ../../secrets.yaml;
    validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/keys.txt";
      generateKey = true;
    };

    secrets = {
      user-password-hash = { };
    };

  };

}
