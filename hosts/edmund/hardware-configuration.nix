{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.supportedFilesystems = [ "btrfs" ];

  boot.initrd.luks.devices.enc = {
    device = "/dev/disk/by-uuid/735fcdf0-7bc9-40f5-9890-9561fc424dd0";
    preLVM = true;
  };

  fileSystems."/" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "compress=zstd"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/enc";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/58CA-E0D5";
    fsType = "vfat";
    options = [
      "uid=0"
      "gid=0"
      "fmask=0077"
      "dmask=0077"
    ];
  };

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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
