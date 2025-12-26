{
  description = "A flake for my NixOS configuration.";

  inputs = {

    # Root NixOS packages and distribution.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager distribution.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Sops for secrets.
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lanzaboote for secure boot.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Local or personal repo for Qtile.
    qtile-flake = {
      # url = "git+file:///home/samu/qtile?ref=new-prompt-cursor";
      url = "github:samunemeth/qtile?ref=new-prompt-cursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let

      # A global set of variables passed to all modules.
      globals = {

        # System and version information.
        system = "x86_64-linux";
        stateVersion = "25.05"; # This should not be changed!

        # User information.
        user = "samu";
        name = "Samu Németh";
        email = "nemeth.samu.0202@gmail.com";

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
      listToAttrs = builtins.foldl' (acc: elem: { "${elem}" = elem; } // acc) { };

      # Get the directories in the hosts folder to get the host names.
      dirContents = builtins.readDir ./hosts;
      hosts = builtins.foldl' (
        acc: elem: if builtins.getAttr elem dirContents == "directory" then acc ++ [ elem ] else acc
      ) [ ] (builtins.attrNames dirContents);

    in
    {

      # Generate NixOS configuration entries from host list.
      nixosConfigurations = builtins.mapAttrs (
        host: _:

        nixpkgs.lib.nixosSystem {

          specialArgs = {
            inherit inputs;
            globals = globals // {
              inherit host;
            };
          };

          modules = [

            # Home Manager
            inputs.home-manager.nixosModules.home-manager

            # Sops
            inputs.sops-nix.nixosModules.sops

            # Main configuration and hardware configuration.
            ./hosts/${host}/configuration.nix
            ./hosts/${host}/hardware-configuration.nix

            # Modules
            ./modules/root.nix

          ];
        }

      ) (listToAttrs hosts);

      # A development shell with python packages needed for running actions.
      # TODO: Convert to a runnable.
      devShells.${globals.system}.default =
        let
          pkgs = nixpkgs.legacyPackages.${globals.system};
        in
        pkgs.mkShell {
          packages = with pkgs.python3Packages; [
            qtile
            cairocffi
          ];
        };

    };
}
