{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  # Kernel parameters.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];

  # Main partition.
  boot.initrd.luks.devices."enc" = {
    device = "/dev/disk/by-label/lb_luks_nixos";
    preLVM = true;
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/lb_nixos";
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd"
      ];
    };
    "/home" = {
      device = "/dev/disk/by-label/lb_nixos";
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd"
      ];
    };
    "/nix" = {
      device = "/dev/disk/by-label/lb_nixos";
      fsType = "btrfs";
      options = [
        "subvol=nix"
        "compress=zstd"
        "noatime"
      ];
    };
  };

  # Boot partition.
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/lb_boot";
    fsType = "vfat";
    options = [
      "uid=0"
      "gid=0"
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Swap partition.
  swapDevices = [
    {
      device = "/dev/disk/by-label/lb_swap";
      encrypted = {
        enable = true;
        label = "swap";
        blkDev = "/dev/disk/by-label/lb_luks_swap";
      };
    }
  ];

  # Some other settings.
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
}
