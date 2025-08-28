{
  description = "A flake for my NixOS configuration.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
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
      password = "$y$j9T$91ZetH54Sf6t8lZD7d7P91$VzSmCPXgC21OnIpeV5hoNFuYmGTQUeJQmJoFwEoLME7";

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
          ./hosts/sulfur/configuration.nix
          ./hosts/sulfur/hardware-configuration.nix
          ./hosts/sulfur/overrides.nix

        ];
      };

      # --- Trunc ---

      trunc = nixpkgs.lib.nixosSystem {

        # Pass the special globals argument to the modules.
        specialArgs = { inherit globals; };

        modules = [
          
          # Home Manager
          inputs.home-manager.nixosModules.home-manager
          
          # CD installation configuration snippet.
          (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")

          # Main Configuration
          ./hosts/trunc/configuration.nix
          ./hosts/trunc/overrides.nix

        ];
      };
    };

    packages.${system}.trunc = self.nixosConfigurations.trunc.config.system.build.isoImage;

  };
}
