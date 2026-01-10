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

      # Define useful functions that can be used anywhere.
      # This is merged into `lib` for the configurations.
      utils = {

        # Convert a flat list to an attribute set.
        listToSimpleAttrs = builtins.foldl' (acc: elem: { "${elem}" = elem; } // acc) { };

        # A version of `lib.mkIf` that always includes a part.
        mkAlwaysThenIf =
          condition: always: ifTrue:
          nixpkgs.lib.mkMerge [
            always
            (nixpkgs.lib.mkIf condition ifTrue)
          ];

        # Create the extra list of special arguments for system modules.
        mkSpecialArgsFor = host: {
          inherit inputs;
          globals = globals // {
            inherit host;
          };
          lib = nixpkgs.lib.extend (_: _: utils);
        };

      };

      # Get the directories in the hosts folder to get the host names.
      dirContents = builtins.readDir ./hosts;
      hosts = builtins.foldl' (
        acc: elem: if builtins.getAttr elem dirContents == "directory" then acc ++ [ elem ] else acc
      ) [ ] (builtins.attrNames dirContents);

      # Function for generating code for multiple architectures.
      # Used for packages not for system configurations.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          sys:
          f {
            pkgs = nixpkgs.legacyPackages.${sys};
            system = sys;
          }
        );

    in
    {

      # Generate NixOS configuration entries from host list.
      nixosConfigurations = builtins.mapAttrs (
        host: _:

        nixpkgs.lib.nixosSystem {
          specialArgs = utils.mkSpecialArgsFor host;
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

      ) (utils.listToSimpleAttrs hosts);

      # Development shells useful for these systems.
      devShells = forAllSystems (
        { pkgs, system, ... }:
        {

          # A development shell with python packages needed for running actions,
          # and working with Qtile locally.
          qtile = pkgs.mkShell {
            packages = with pkgs; [
              python3Packages.qtile
              python3Packages.cairocffi
            ];
          };

          # A development shell for setting up a new system.
          setup = pkgs.mkShell {
            packages = with pkgs; [
              git
              vim
              lf

              # For faster finding.
              ripgrep
              fd

              # For some system info.
              lm_sensors
              fastfetchMinimal
              btop
              nix-tree

              # All of the packages below should be there by default.
              util-linux
              cryptsetup
              btrfs-progs
              curl
            ];
          };

        }
      );

      # Expose packages accessed with `nix build` on the flake.
      packages = forAllSystems (
        { ... }:

        # Expose preconfigured applications from all hosts.
        (builtins.mapAttrs (_: v: v.config.modules.export-apps) self.nixosConfigurations)

        # Expose the build command for the ISO image.
        // {
          iso = (import ./iso/image.nix) { inherit nixpkgs utils; };
        }
      );

    };
}
