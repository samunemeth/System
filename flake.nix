{
  description = "A flake for my NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
  let
    
    # System type.
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

    # A global set of variables passed to all modules.
    globals = {

      # System and version information.
      inherit system; 
      stateVersion = "25.05"; # This should not be changed!

      # User information.
      user = "samu";
      name = "Samu Németh";
      email = "nemeth.samu.0202@gmail.com";

    };

  in
  {

    nixosConfigurations = {

      # --- Sulfur ---

      sulfur = nixpkgs.lib.nixosSystem {

        # Pass the special globals argument to the modules.
        specialArgs = { inherit globals; };

        modules = [
          
          # Home Manager
          inputs.home-manager.nixosModules.home-manager

          # Main Configuration
          ./sulfur/configuration.nix
          ./sulfur/hardware-configuration.nix

        ];
      };
    };

  };
}
