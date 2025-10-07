{
  description = "A flake for my NixOS configuration.";

  inputs = {

    # Root NixOS packages and distribution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Home Manager distribution.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # WSL support distribution.
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs: {


    # A global set of variables passed to all modules.
    globals = {

      # System and version information.
      system = "x86_64-linux";
      stateVersion = "25.05"; # This should not be changed!

      # User information.
      user = "samu";
      name = "Samu Németh";
      email = "nemeth.samu.0202@gmail.com";
      password = "$y$j9T$91ZetH54Sf6t8lZD7d7P91$VzSmCPXgC21OnIpeV5hoNFuYmGTQUeJQmJoFwEoLME7";

      # Color configuration.
      colors = {
        dark = true;
        background = {
          main = "#14161B";
          contrast = "#0A0B0E";
        };
        foreground = {
          main = "#F2F4F3";
          soft = "#D0D6DD";
          error = "#DC4332";
        };
      };

    };

    # Define useful functions.
    listToAttrs = builtins.foldl' (acc: elem: { "${elem}" = elem; } // acc) {};

    # Get the directories in the hosts folder to get the host names.
    dirContents = builtins.readDir ./hosts;
    hosts = builtins.foldl'
      (acc: elem: if builtins.getAttr elem self.dirContents == "directory" then acc ++ [elem] else acc)
      [] (builtins.attrNames self.dirContents);

    # Generate NixOS configuration entries from host list.
    nixosConfigurations = builtins.mapAttrs (host: _: 

      nixpkgs.lib.nixosSystem {

        specialArgs = {
          inherit inputs;
          globals = self.globals // { inherit host; };
        };

        modules = [
          
          # Home Manager
          inputs.home-manager.nixosModules.home-manager

          # Main configuration and hardware configuration.
          ./hosts/${host}/configuration.nix
          ./hosts/${host}/hardware-configuration.nix

          # Modules
          ./modules/root.nix

        ];
      }

    ) (self.listToAttrs self.hosts);


  };
}
