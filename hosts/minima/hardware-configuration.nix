{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
