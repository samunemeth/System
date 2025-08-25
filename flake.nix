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
    
    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };

    globals = {
      inherit system; 
      stateVersion = "25.05"; # This should not be changed!
      user = "samu";
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

        ];
      };
    };

  };
}
