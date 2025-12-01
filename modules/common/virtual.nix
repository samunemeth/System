# --- Virtualisation ---

{
  config,
  pkgs,
  lib,
  globals,
  ...
}:
{

  # Load kernel virtualisation modules.
  boot.kernelModules = [ "kvm" ];
  users.groups.kvm.members = [ globals.user ];

  programs.bash.interactiveShellInit = # bash
    ''
      # Create a NixOS VM from this flake.
      makevm () {
        local host="''${1:-$HOSTNAME}"
        mkdir -p /tmp/nixosvmrun || return
        cd /tmp/nixosvmrun || return
        nixos-rebuild build-vm --flake "$HOME/System/#$host" && "./result/bin/run-$host-vm"
        cd - > /dev/null || true
        rm -rf /tmp/nixosvmrun
      }
    '';

  # Following configuration is added only when building a VM.
  virtualisation.vmVariant = {

    # WARN: Sops-nix is currently not working from inside the VM.
    # > I do not think that this is a big issue, as most secrets are not needed
    # > inside the VM. Later if needed this could be figured out.

    virtualisation = {

      # Allocate resources to the VM.
      memorySize = 4096;
      cores = 4;
      # NOTE: This is not respected for some reason?
      # > It works for now so I am not going to complain too much.
      resolution = {
        x = 960;
        y = 540;
      };
      qemu.options = [
        "-display gtk,zoom-to-fit=on,grab-on-hover=on,gl=on,full-screen=on,show-menubar=off"
        "-vga std"
        "-enable-kvm"
      ];

      # Share the directory containing the system configuration.
      sharedDirectories = {
        system-config = {
          source = "/home/${globals.user}/System";
          target = "/home/${globals.user}/System";
        };
      };
    };

    # Some tweaking is needed for the user to work.
    users.users.${globals.user} = {
      password = "vmtest";
      group = "nixosvmtest";
      hashedPasswordFile = lib.mkForce null;
    };
    users.groups.nixosvmtest = { };

    # Remove Firefox to improve performance.
    modules.apps.firefox = lib.mkForce false;

    # Indicate to some software that we are inside a VM.
    environment.sessionVariables.IS_VM = "1";

    # --- Testing Configuration ---
    # This is where you can put configuration settings that you want to test
    # in the VM without messing with your whole machine.

  };

}
