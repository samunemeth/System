# --- System ---

{
  config,
  pkgs,
  lib,
  globals,
  inputs, # For setting the nix path.
  ...
}:
{

  options.modules = {
    system.isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Weather the machine is a desktop machine. If true, disables touch
        input gestures.
      '';
    };
  };

  config = {

    # Set host name default.
    networking.hostName = globals.host;

    # Enable sound with Pulse Audio by default.
    services.pulseaudio.enable = true;
    services.pipewire.enable = false;
    security.rtkit.enable = true;

    # Enable flakes.
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Add nixpkgs to the nix path. This is needed for nixd.
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Write JSON files with the globals and module settings.
    environment.etc."system-options/globals.json".text = builtins.toJSON globals;
    environment.etc."system-options/modules.json".text = builtins.toJSON (
      # Make sure to remove the exported apps, as including this in the JSON
      # would force them to be installed regardless of the settings.
      builtins.removeAttrs config.modules [ "export-apps" ]
    );

    # Set state versions.
    system.stateVersion = globals.stateVersion;

    # Allow unfree packages.
    nixpkgs = {
      system = globals.system;
      config.allowUnfree = true;
    };

    # Automatically optimise packages and collect garbage.
    nix.settings.auto-optimise-store = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      persistent = true;
    };

  };
}
