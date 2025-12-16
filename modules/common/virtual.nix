# --- Template ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For custom flake inputs.
  ...
}:
{

  # Load kernel virtualisation modules.
  boot.kernelModules = [
    "kvm"
    "kvm_amd"
    # "kvm_intel"
  ];
  users.groups.kvm.members = [ globals.user ];

  programs.bash.interactiveShellInit = # bash
    ''
      # Rebuild NixOS from a flake.
      makevm () {
        mkdir -p /tmp/nixosvmrun
        cd /tmp/nixosvmrun
        nixos-rebuild build-vm --flake ~/System/#$1 && ./result/bin/run-$1-vm
        cd - > /dev/null
        rm -rf /tmp/nixosvmrun
      }
    '';

  # following configuration is added only when building VM with build-vm
  virtualisation.vmVariant = {

    # BUG: Sops-nix does not work inside virtualisation.
    virtualisation = {

      # Allocate resources to the VM.
      memorySize = 4096;
      cores = 8;
      # This is not respected for some reason?
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

    # --- Testing Configuration ---
    # This is where you can put configuration settings that you want to test
    # in the VM without messing with your whole machine.

  };

}
