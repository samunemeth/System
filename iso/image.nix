{ nixpkgs, utils, ... }:
let

  # Generate a simple ISO image.
  isoSystem = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = utils.mkSpecialArgsFor "iso";
    modules = [
      "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ./configuration.nix
    ];
  };
  isoImage = isoSystem.config.system.build.isoImage;

in
isoImage
